#!/usr/bin/env python
# -*- coding: utf-8 -*-


import json
import logging
import os
import struct
import types
import ykman.logging_setup

from base64 import b32decode
from binascii import b2a_hex, a2b_hex
from fido2.ctap import CtapError

from ykman.descriptor import get_descriptors
from ykman.driver_otp import YkpersError
from ykman.device import device_config
from ykman.otp import OtpController
from ykman.fido import Fido2Controller
from ykman.piv import PivController
from ykman.scancodes import KEYBOARD_LAYOUT
from ykman.util import (
    APPLICATION, TRANSPORT, Mode, modhex_encode, modhex_decode,
    generate_static_pw)


logger = logging.getLogger(__name__)


def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped


class PivContextManager:
    def __init__(self, dev):
        self._dev = dev

    def __enter__(self):
        return PivController(self._dev.driver)

    def __exit__(self, exc_type, exc_value, traceback):
        self._dev.close()


class Controller(object):
    _descriptor = None
    _dev_info = None

    def __init__(self):
        # Wrap all return values as JSON.
        for f in dir(self):
            if not f.startswith('_'):
                func = getattr(self, f)
                if isinstance(func, types.MethodType):
                    setattr(self, f, as_json(func))

    def count_devices(self):
        return len(list(get_descriptors()))

    def _open_device(self, transports=sum(TRANSPORT)):
        return self._descriptor.open_device(transports=transports)

    def _open_piv(self):
        return PivContextManager(
                self._descriptor.open_device(transports=TRANSPORT.CCID))

    def refresh(self):
        descriptors = list(get_descriptors())
        if len(descriptors) != 1:
            self._descriptor = None
            return {'success': False, 'error': 'Multiple devices', 'dev': None}
        desc = descriptors[0]

        # If we have a cached descriptor
        if self._descriptor:
            # Same device, return
            if desc.fingerprint == self._descriptor.fingerprint:
                return {'success': True, 'error': None, 'dev': self._dev_info}

        self._descriptor = desc

        try:
            with self._open_device() as dev:
                if not dev:
                    return {
                        'success': False,
                        'error': 'No device',
                        'dev': None
                    }

                self._dev_info = {
                        'name': dev.device_name,
                        'version': '.'.join(str(x) for x in dev.version),
                        'serial': dev.serial or '',
                        'usb_enabled': [
                            a.name for a in APPLICATION
                            if a & dev.config.usb_enabled],
                        'usb_supported': [
                            a.name for a in APPLICATION
                            if a & dev.config.usb_supported],
                        'usb_interfaces_supported': [
                            t.name for t in TRANSPORT
                            if t & dev.config.usb_supported],
                        'nfc_enabled': [
                            a.name for a in APPLICATION
                            if a & dev.config.nfc_enabled],
                        'nfc_supported': [
                            a.name for a in APPLICATION
                            if a & dev.config.nfc_supported],
                        'usb_interfaces_enabled': str(dev.mode).split('+'),
                        'can_write_config': dev.can_write_config,
                        'configuration_locked': dev.config.configuration_locked
                    }
                return {'success': True, 'error': None, 'dev': self._dev_info}

        except Exception as e:
            logger.error('Failed to open device', exc_info=e)
            return {'success': False, 'error': str(e), 'dev': None}

    def write_config(self, usb_applications, nfc_applications, lock_code):
        usb_enabled = 0x00
        nfc_enabled = 0x00
        for app in usb_applications:
            usb_enabled |= APPLICATION[app]
        for app in nfc_applications:
            nfc_enabled |= APPLICATION[app]
        try:
            with self._open_device() as dev:

                if lock_code:
                    lock_code = a2b_hex(lock_code)
                    if len(lock_code) != 16:
                        return {'success': False,
                                'error': 'Lock code not 16 bytes'}
                dev.write_config(
                    device_config(
                        usb_enabled=usb_enabled,
                        nfc_enabled=nfc_enabled,
                        ),
                    reboot=True,
                    lock_key=lock_code)
                return {'success': True, 'error': None}
        except Exception as e:
            logger.error('Failed to write config', exc_info=e)
            return {'success': False, 'error': str(e)}

    def set_mode(self, interfaces):
        try:
            with self._open_device() as dev:
                transports = sum([TRANSPORT[i] for i in interfaces])
                dev.mode = Mode(transports & TRANSPORT.usb_transports())
        except Exception as e:
            logger.error('Failed to set mode', exc_info=e)
            return str(e)

    def slots_status(self):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                return {'status': controller.slot_status, 'error': None}
        except YkpersError as e:
            if e.errno == 4:
                return {'status': None, 'error': 'timeout'}
            logger.error('Failed to read slot status', exc_info=e)
            return {'status': None, 'error': str(e)}
        except Exception as e:
            logger.error('Failed to read slot status', exc_info=e)
            return {'status': None, 'error': str(e)}

    def erase_slot(self, slot):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.zap_slot(slot)
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def swap_slots(self):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.swap_slots()
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def serial_modhex(self):
        with self._open_device(TRANSPORT.OTP) as dev:
            return modhex_encode(b'\xff\x00' + struct.pack(b'>I', dev.serial))

    def generate_static_pw(self, keyboard_layout):
        return generate_static_pw(
            38, KEYBOARD_LAYOUT[keyboard_layout]).decode('utf-8')

    def random_uid(self):
        return b2a_hex(os.urandom(6)).decode('ascii')

    def random_key(self, bytes):
        return b2a_hex(os.urandom(int(bytes))).decode('ascii')

    def program_otp(self, slot, public_id, private_id, key):
        try:
            key = a2b_hex(key)
            public_id = modhex_decode(public_id)
            private_id = a2b_hex(private_id)
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_otp(slot, key, public_id, private_id)
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def program_challenge_response(self, slot, key, touch):
        try:
            key = a2b_hex(key)
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_chalresp(slot, key, touch)
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def program_static_password(self, slot, key, keyboard_layout):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_static(
                    slot, key,
                    keyboard_layout=KEYBOARD_LAYOUT[keyboard_layout])
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def program_oath_hotp(self, slot, key, digits):
        try:
            unpadded = key.upper().rstrip('=').replace(' ', '')
            key = b32decode(unpadded + '=' * (-len(unpadded) % 8))
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_hotp(slot, key, hotp8=(digits == 8))
            return {'success': True, 'error': None}
        except YkpersError as e:
            if e.errno == 3:
                return {'success': False, 'error': 'write error'}
            return {'success': False, 'error': str(e)}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def fido_has_pin(self):
        try:
            with self._open_device(TRANSPORT.FIDO) as dev:
                dev = self._descriptor.open_device(TRANSPORT.FIDO)
                controller = Fido2Controller(dev.driver)
            return {'hasPin': controller.has_pin, 'error': None}
        except Exception as e:
            logger.error('Failed to read if PIN is set', exc_info=e)
            return {'hasPin': None, 'error': str(e)}

    def fido_pin_retries(self):
        try:
            with self._open_device(TRANSPORT.FIDO) as dev:
                dev = self._descriptor.open_device(TRANSPORT.FIDO)
                controller = Fido2Controller(dev.driver)
                return {'retries': controller.get_pin_retries(), 'error': None}
        except CtapError as e:
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return {
                    'retries': None,
                    'error': 'PIN authentication is currently blocked. '
                             'Remove and re-insert the YubiKey.'}
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return {'retries': None, 'error': 'PIN is blocked.'}
        except Exception as e:
            logger.error('Failed to read PIN retries', exc_info=e)
            return {'retries': None, 'error': str(e)}

    def fido_set_pin(self, new_pin):
        try:
            with self._open_device(TRANSPORT.FIDO) as dev:
                dev = self._descriptor.open_device(TRANSPORT.FIDO)
                controller = Fido2Controller(dev.driver)
                controller.set_pin(new_pin)
                return {'success': True, 'error': None}
        except CtapError as e:
            if e.code == CtapError.ERR.INVALID_LENGTH:
                return {'success': False, 'error': 'too long'}
            logger.error('Failed to set PIN', exc_info=e)
            return {'success': False, 'error': str(e)}
        except Exception as e:
            logger.error('Failed to set PIN', exc_info=e)
            return {'success': False, 'error': str(e)}

    def fido_change_pin(self, current_pin, new_pin):
        try:
            with self._open_device(TRANSPORT.FIDO) as dev:
                controller = Fido2Controller(dev.driver)
                controller.change_pin(old_pin=current_pin, new_pin=new_pin)
                return {'success': True, 'error': None}
        except CtapError as e:
            if e.code == CtapError.ERR.INVALID_LENGTH:
                return {'success': False,
                        'error': 'too long'}
            if e.code == CtapError.ERR.PIN_INVALID:
                return {'success': False,
                        'error': 'wrong pin'}
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return {'success': False,
                        'error': 'currently blocked'}
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return {'success': False, 'error': 'blocked'}
            logger.error('Failed to set PIN', exc_info=e)
            return {'success': False, 'error': str(e)}
        except Exception as e:
            logger.error('Failed to set PIN', exc_info=e)
            return {'success': False, 'error': str(e)}

    def fido_reset(self):
        try:
            with self._open_device(TRANSPORT.FIDO) as dev:
                controller = Fido2Controller(dev.driver)
                controller.reset()
                return {'success': True, 'error': None}
        except CtapError as e:
            if e.code == CtapError.ERR.NOT_ALLOWED:
                return {'success': False, 'error': 'not allowed'}
            if e.code == CtapError.ERR.ACTION_TIMEOUT:
                return {'success': False, 'error': 'touch timeout'}
            else:
                logger.error('Reset throwed an exception', exc_info=e)
                return {'success': False, 'error': str(e)}
        except Exception as e:
            logger.error('Reset throwed an exception', exc_info=e)
            return {'success': False, 'error': str(e)}

    def piv_reset(self):
        try:
            with self._open_piv() as controller:
                controller.reset()
                return {'success': True, 'error': None}
        except Exception as e:
            logger.error('Failed to reset PIV application', exc_info=e)
            return {'success': False, 'error': str(e)}


controller = None


def init_with_logging(log_level, log_file=None):
    logging_setup = as_json(ykman.logging_setup.setup)
    logging_setup(log_level, log_file)

    init()


def init():
    global controller
    controller = Controller()
    controller.refresh()
