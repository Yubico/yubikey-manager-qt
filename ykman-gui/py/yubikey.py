#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
import json
import logging
import types
import struct
import ykman.logging_setup

from base64 import b32decode
from binascii import b2a_hex, a2b_hex, Error

from ykman.descriptor import get_descriptors
from ykman.util import (
    CAPABILITY, TRANSPORT, Mode, modhex_encode, modhex_decode,
    generate_static_pw)
from ykman.driver import ModeSwitchError
from ykman.driver_otp import YkpersError
from ykman.opgp import OpgpController, KEY_SLOT
from ykman.fido import Fido2Controller, CTAP2Error, CTAP2_ERR

logger = logging.getLogger(__name__)


def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped


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

    def refresh(self):
        descriptors = list(get_descriptors())
        if len(descriptors) != 1:
            self._descriptor = None
            return

        desc = descriptors[0]
        if desc.fingerprint != (
                self._descriptor.fingerprint if self._descriptor else None):
            dev = desc.open_device()
            if not dev:
                return
            self._dev_info = {
                'name': dev.device_name,
                'version': '.'.join(str(x) for x in dev.version),
                'serial': dev.serial or '',
                'enabled': [c.name for c in CAPABILITY if c & dev.enabled],
                'capabilities': [
                    c.name for c in CAPABILITY if c & dev.capabilities],
                'connections': [
                    t.name for t in TRANSPORT if t & dev.capabilities]
            }
            self._descriptor = desc

        return self._dev_info

    def set_mode(self, connections):
        logger.debug('connections: %s', connections)

        dev = self._descriptor.open_device()
        logger.debug('dev: %s', dev)

        try:
            transports = sum([TRANSPORT[c] for c in connections])
            dev.mode = Mode(transports & TRANSPORT.usb_transports())
        except ModeSwitchError as e:
            logger.error('Failed to set modes', exc_info=e)
            return str(e)

    def slots_status(self):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        return dev.driver.slot_status

    def erase_slot(self, slot):
        try:
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.zap_slot(slot)
        except YkpersError as e:
            return e.errno

    def swap_slots(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.swap_slots()
        except YkpersError as e:
            return e.errno

    def serial_modhex(self):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        return modhex_encode(b'\xff\x00' + struct.pack(b'>I', dev.serial))

    def generate_static_pw(self):
        return generate_static_pw(38).decode('utf-8')

    def random_uid(self):
        return b2a_hex(os.urandom(6)).decode('ascii')

    def random_key(self, bytes):
        return b2a_hex(os.urandom(int(bytes))).decode('ascii')

    def program_otp(self, slot, public_id, private_id, key):
        try:
            key = a2b_hex(key)
            public_id = modhex_decode(public_id)
            private_id = a2b_hex(private_id)
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.program_otp(slot, key, public_id, private_id)
        except YkpersError as e:
            return e.errno

    def program_challenge_response(self, slot, key, touch):
        try:
            key = a2b_hex(key)
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.program_chalresp(slot, key, touch)
        except YkpersError as e:
            return e.errno

    def program_static_password(self, slot, key):
        try:
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.program_static(slot, key)
        except YkpersError as e:
            return e.errno

    def program_oath_hotp(self, slot, key, digits):
        try:
            unpadded = key.upper().rstrip('=').replace(' ', '')
            key = b32decode(unpadded + '=' * (-len(unpadded) % 8))
            dev = self._descriptor.open_device(TRANSPORT.OTP)
            dev.driver.program_hotp(slot, key, hotp8=(digits == 8))
        except Error as e:
            return str(e)
        except YkpersError as e:
            return e.errno

    def openpgp_reset(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            controller.reset()
            return True
        except Exception as e:
            logger.error('Failed to reset OpenPGP applet', exc_info=e)
            return False

    def openpgp_get_touch(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            auth = controller.get_touch(KEY_SLOT.AUTHENTICATE)
            enc = controller.get_touch(KEY_SLOT.ENCRYPT)
            sig = controller.get_touch(KEY_SLOT.SIGN)
            return [auth, enc, sig]
        except Exception as e:
            logger.error('Failed to get OpenPGP touch policy', exc_info=e)
            return None

    def openpgp_set_touch(self, admin_pin, auth, enc, sig):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            if auth >= 0:
                controller.set_touch(
                    KEY_SLOT.AUTHENTICATE, int(auth), admin_pin.encode())
            if enc >= 0:
                controller.set_touch(
                    KEY_SLOT.ENCRYPT, int(enc), admin_pin.encode())
            if sig >= 0:
                controller.set_touch(
                    KEY_SLOT.SIGN, int(sig), admin_pin.encode())
            return True
        except Exception as e:
            logger.error('Failed to set OpenPGP touch policy', exc_info=e)
            return False

    def openpgp_set_pin_retries(
            self, admin_pin, pin_retries, reset_code_retries,
            admin_pin_retries):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            controller.set_pin_retries(
                int(pin_retries), int(reset_code_retries),
                int(admin_pin_retries), admin_pin.encode())
            return True
        except Exception as e:
            logger.error('Failed to set OpenPGP PIN retries', exc_info=e)
            return False

    def openpgp_get_version(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            return controller.version
        except Exception as e:
            logger.error('Failed to get OpenPGP applet version', exc_info=e)
            return None

    def openpgp_get_remaining_pin_retries(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.CCID)
            controller = OpgpController(dev.driver)
            return controller.get_remaining_pin_tries()
        except Exception as e:
            logger.error('Failed to get remaining OpenPGP PIN retries',
                         exc_info=e)
            return None

    def fido_has_pin(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.U2F)
            controller = Fido2Controller(dev.driver)
            return controller.has_pin
        except Exception as e:
            logger.error('Failed to read if PIN is set', exc_info=e)

    def fido_pin_retries(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.U2F)
            controller = Fido2Controller(dev.driver)
            return controller.get_pin_retries()
        except Exception as e:
            logger.error('Failed to read PIN retries', exc_info=e)

    def fido_set_pin(self, new_pin):
        try:
            logger.debug(self._descriptor)
            dev = self._descriptor.open_device(TRANSPORT.U2F)
            controller = Fido2Controller(dev.driver)
            controller.set_pin(new_pin)
            return None
        except Exception as e:
            logger.error('Failed to set PIN', exc_info=e)
            return e

    def fido_change_pin(self, current_pin, new_pin):
        try:
            dev = self._descriptor.open_device(TRANSPORT.U2F)
            controller = Fido2Controller(dev.driver)
            controller.change_pin(old_pin=current_pin, new_pin=new_pin)
            return None
        except CTAP2Error as e:
            if e.code == CTAP2_ERR.PIN_INVALID:
                return 'The current PIN is wrong.'
            if e.code == CTAP2_ERR.PIN_AUTH_BLOCKED:
                return 'PIN authentication is currently blocked. ' \
                    'Remove and re-insert the YubiKey.'
            if e.code == CTAP2_ERR.PIN_BLOCKED:
                return 'PIN is blocked.'

    def fido_reset(self):
        try:
            dev = self._descriptor.open_device(TRANSPORT.U2F)
            controller = Fido2Controller(dev.driver)
            controller.reset()
            return None
        except CTAP2Error as e:
            if e.code == CTAP2_ERR.NOT_ALLOWED:
                return 'Failed to reset the YubiKey. The reset command' \
                    'must be triggered within 10 seconds after the ' \
                    'YubiKey is inserted.'
        except Exception as e:
            logger.error('Reset throwed an exception', exc_info=e)


controller = None


def init_with_logging(log_level, log_file=None):
    logging_setup = as_json(ykman.logging_setup.setup)
    logging_setup(log_level, log_file)

    init()


def init():
    global controller
    controller = Controller()
    controller.refresh()
