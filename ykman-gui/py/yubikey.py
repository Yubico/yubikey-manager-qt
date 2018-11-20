#!/usr/bin/env python
# -*- coding: utf-8 -*-


import datetime
import json
import logging
import os
import pyotherside
import struct
import types
import urllib.parse
import ykman.logging_setup

from base64 import b32decode
from binascii import b2a_hex, a2b_hex
from fido2.ctap import CtapError
from cryptography import x509
from cryptography.hazmat.primitives import serialization
from ykman.descriptor import get_descriptors
from ykman.device import device_config
from ykman.otp import OtpController
from ykman.fido import Fido2Controller
from ykman.driver_ccid import APDUError, SW
from ykman.driver_otp import YkpersError, libversion as ykpers_version
from ykman.piv import (
    PivController, ALGO, PIN_POLICY, SLOT, TOUCH_POLICY, AuthenticationBlocked,
    AuthenticationFailed, BadFormat, WrongPin, WrongPuk)
from ykman.scancodes import KEYBOARD_LAYOUT
from ykman.util import (
    APPLICATION, TRANSPORT, Mode, modhex_encode, modhex_decode,
    generate_static_pw, parse_certificate, parse_private_key)

logger = logging.getLogger(__name__)


def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped


def piv_catch_error(f):
    def wrapped(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as e:
            logger.error('PIV operation failed', exc_info=e)
            return {
                'success': False,
                'error_id': None,
                'error_message': str(e),
            }
    return wrapped


class OtpContextManager(object):
    def __init__(self, dev):
        self._dev = dev

    def __enter__(self):
        return OtpController(self._dev.driver)

    def __exit__(self, exc_type, exc_value, traceback):
        self._dev.close()


class Fido2ContextManager(object):
    def __init__(self, dev):
        self._dev = dev

    def __enter__(self):
        return Fido2Controller(self._dev.driver)

    def __exit__(self, exc_type, exc_value, traceback):
        self._dev.close()


class PivContextManager(object):
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

    def _open_otp_controller(self):
        if ykpers_version is None:
            raise Exception(
                'Could not find the "ykpers" library. Please ensure that '
                'YubiKey Manager was installed correctly.')
        return OtpContextManager(
            self._descriptor.open_device(transports=TRANSPORT.OTP))

    def _open_fido2_controller(self):
        return Fido2ContextManager(
            self._descriptor.open_device(transports=TRANSPORT.FIDO))

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

    @piv_catch_error
    def refresh_piv(self):
        with self._open_piv() as piv_controller:
            return {
                'certs': self._piv_list_certificates(piv_controller),
                'has_derived_key': piv_controller.has_derived_key,
                'has_protected_key': piv_controller.has_protected_key,
                'has_stored_key': piv_controller.has_stored_key,
                'pin_tries': piv_controller.get_pin_tries(),
                'puk_blocked': piv_controller.puk_blocked,
                'success': True,
            }

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
            with self._open_otp_controller() as controller:
                return {
                    'success': True,
                    'status': controller.slot_status,
                    'error': None}
        except YkpersError as e:
            if e.errno == 4:
                return {'success': False, 'status': None, 'error': 'timeout'}
            logger.error('Failed to read slot status', exc_info=e)
            return {'success': False, 'status': None, 'error': str(e)}
        except Exception as e:
            logger.error('Failed to read slot status', exc_info=e)
            return {'success': False, 'status': None, 'error': str(e)}

    def erase_slot(self, slot):
        try:
            with self._open_otp_controller() as controller:
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
            with self._open_otp_controller() as controller:
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
            with self._open_otp_controller() as controller:
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
            with self._open_otp_controller() as controller:
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
            with self._open_otp_controller() as controller:
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
            with self._open_otp_controller() as controller:
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
            with self._open_fido2_controller() as controller:
                return {
                    'success': True,
                    'hasPin': controller.has_pin,
                    'error': None}
        except Exception as e:
            logger.error('Failed to read if PIN is set', exc_info=e)
            return {'success': False, 'hasPin': None, 'error': str(e)}

    def fido_pin_retries(self):
        try:
            with self._open_fido2_controller() as controller:
                return {
                    'success': True,
                    'retries': controller.get_pin_retries(),
                    'error': None}
        except CtapError as e:
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return {
                    'success': False,
                    'retries': None,
                    'error': 'PIN authentication is currently blocked. '
                             'Remove and re-insert the YubiKey.'}
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return {
                    'success': False,
                    'retries': None,
                    'error': 'PIN is blocked.'}
        except Exception as e:
            logger.error('Failed to read PIN retries', exc_info=e)
            return {'success': False, 'retries': None, 'error': str(e)}

    def fido_set_pin(self, new_pin):
        try:
            with self._open_fido2_controller() as controller:
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
            with self._open_fido2_controller() as controller:
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
            with self._open_fido2_controller() as controller:
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

    @piv_catch_error
    def piv_reset(self):
        with self._open_piv() as controller:
            controller.reset()
            return {'success': True}

    def _piv_list_certificates(self, controller):
        return {
            SLOT(slot).name: _piv_serialise_cert(slot, cert) for slot, cert in controller.list_certificates().items()  # noqa: E501
        }

    @piv_catch_error
    def piv_delete_certificate(self, slot_name, pin=None, mgm_key_hex=None):
        logger.debug('piv_delete_certificate %s', slot_name)

        with self._open_piv() as piv_controller:
            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
            if auth_failed:
                return auth_failed

            piv_controller.delete_certificate(SLOT[slot_name])
            return {'success': True}

    @piv_catch_error
    def piv_generate_certificate(
            self, slot_name, algorithm, common_name, expiration_date,
            self_sign=True, csr_file_url=None, pin=None, mgm_key_hex=None,
            pin_policy=None, touch_policy=None):
        logger.debug('slot_name=%s algorithm=%s common_name=%s '
                     'expiration_date=%s self_sign=%s csr_file_url=%s '
                     'pin_policy=%s touch_policy=%s',
                     slot_name, algorithm, common_name, expiration_date,
                     self_sign, csr_file_url, pin_policy, touch_policy)

        file_path = urllib.parse.urlparse(csr_file_url).path

        with self._open_piv() as piv_controller:
            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
            if auth_failed:
                return auth_failed

            pin_failed = self._piv_verify_pin(piv_controller, pin)
            if pin_failed:
                return pin_failed

            if self_sign:
                now = datetime.datetime.now()
                try:
                    year = int(expiration_date[0:4])
                    month = int(expiration_date[(4+1):(4+1+2)])
                    day = int(expiration_date[(4+1+2+1):(4+1+2+1+2)])
                    valid_to = datetime.datetime(year, month, day)
                except ValueError as e:
                    logger.debug(
                        'Failed to parse date: ' + expiration_date,
                        exc_info=e)
                    return {
                        'success': False,
                        'error_id': 'invalid_iso8601_date',
                        'date': expiration_date,
                    }

            unsupported_policy = self._piv_check_policies(
                piv_controller, pin_policy=pin_policy,
                touch_policy=touch_policy)
            if unsupported_policy:
                return unsupported_policy

            public_key = piv_controller.generate_key(
                SLOT[slot_name], ALGO[algorithm],
                pin_policy=(PIN_POLICY.from_string(pin_policy)
                            if pin_policy else PIN_POLICY.DEFAULT),
                touch_policy=(TOUCH_POLICY.from_string(touch_policy)
                              if touch_policy else TOUCH_POLICY.DEFAULT))

            if self_sign:
                try:
                    piv_controller.generate_self_signed_certificate(
                        SLOT[slot_name], public_key, common_name, now,
                        valid_to)
                except APDUError as e:
                    if e.sw == SW.SECURITY_CONDITION_NOT_SATISFIED:
                        return {
                            'success': False,
                            'error_id': 'pin_required',
                        }
                    raise

            else:
                csr = piv_controller.generate_certificate_signing_request(
                    SLOT[slot_name], public_key, common_name)

                with open(file_path, 'w+b') as csr_file:
                    csr_file.write(csr.public_bytes(
                        encoding=serialization.Encoding.PEM))

            return {'success': True}

    @piv_catch_error
    def piv_change_pin(self, old_pin, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.change_pin(old_pin, new_pin)
                logger.debug('PIN change successful!')
                return {'success': True}

            except AuthenticationBlocked as e:
                return {
                    'success': False,
                    'error_id': 'pin_blocked',
                }

            except WrongPin as e:
                return {
                    'success': False,
                    'error_id': 'wrong_pin',
                    'tries_left': e.tries_left,
                }

            except APDUError as e:
                if e.sw == SW.INCORRECT_PARAMETERS:
                    return {
                        'success': False,
                        'error_id': 'incorrect_parameters',
                    }

                tries_left = piv_controller.get_pin_tries()
                logger.debug('PIN change failed. %s tries left.',
                             tries_left, exc_info=e)
                return {
                    'success': False,
                    'tries_left': tries_left,
                }

    @piv_catch_error
    def piv_change_puk(self, old_puk, new_puk):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.change_puk(old_puk, new_puk)
                return {'success': True}

            except AuthenticationBlocked as e:
                return {
                    'success': False,
                    'error_id': 'puk_blocked',
                }

            except WrongPuk as e:
                return {
                    'success': False,
                    'error_id': 'wrong_puk',
                    'tries_left': e.tries_left,
                }

    @piv_catch_error
    def piv_generate_random_mgm_key(self):
        return b2a_hex(ykman.piv.generate_random_management_key()).decode(
            'utf-8')

    @piv_catch_error
    def piv_change_mgm_key(self, pin, current_key_hex, new_key_hex,
                           store_on_device=False):
        with self._open_piv() as piv_controller:

            if piv_controller.has_protected_key or store_on_device:
                pin_failed = self._piv_verify_pin(
                    piv_controller, pin=pin)
                if pin_failed:
                    return pin_failed

            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=current_key_hex)
            if auth_failed:
                return auth_failed

            try:
                new_key = a2b_hex(new_key_hex) if new_key_hex else None
            except Exception as e:
                logger.debug('Failed to parse new management key', exc_info=e)
                return {
                    'success': False,
                    'error_id': 'new_mgm_key_bad_hex'
                  }

            if new_key is not None and len(new_key) != 24:
                logger.debug('Wrong length for new management key: %d',
                             len(new_key))
                return {
                    'success': False,
                    'error_id': 'new_mgm_key_bad_length'
                }

            piv_controller.set_mgm_key(
                new_key, touch=False, store_on_device=store_on_device)
            return {'success': True}

    @piv_catch_error
    def piv_unblock_pin(self, puk, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.unblock_pin(puk, new_pin)
                return {'success': True}

            except AuthenticationBlocked as e:
                return {
                    'success': False,
                    'error_id': 'puk_blocked',
                }

            except WrongPuk as e:
                return {
                    'success': False,
                    'error_id': 'wrong_puk',
                    'tries_left': e.tries_left,
                }

            except Exception as e:
                logger.error('PIN unblock failed.', exc_info=e)
                return {
                    'success': False,
                    'message': str(e),
                }

    @piv_catch_error
    def piv_can_parse(self, file_url):
        file_path = urllib.parse.urlparse(file_url).path
        with open(file_path, 'r+b') as file:
            data = file.read()
            try:
                parse_certificate(data, password=None)
                return {'success': True, 'error': None}
            except (ValueError, TypeError):
                pass
            try:
                parse_private_key(data, password=None)
                return {'success': True, 'error': None}
            except (ValueError, TypeError):
                pass
        raise ValueError('Failed to parse certificate or key')

    @piv_catch_error
    def piv_import_file(self, slot, file_url, password=None,
                        pin=None, mgm_key=None):
        is_cert = False
        is_private_key = False
        file_path = urllib.parse.urlparse(file_url).path
        file_path_windows = file_path[1:]
        if os.name == 'nt':
            file_path = file_path_windows
        if password:
            password = password.encode()
        with open(file_path, 'r+b') as file:
            data = file.read()
            try:
                cert = parse_certificate(data, password)
                is_cert = True
            except (ValueError, TypeError):
                pass
            try:
                private_key = parse_private_key(data, password)
                is_private_key = True
            except (ValueError, TypeError):
                pass
            with self._open_piv() as controller:
                auth_failed = self._piv_ensure_authenticated(
                    controller, pin, mgm_key)
                if auth_failed:
                    return auth_failed
                if is_cert:
                    controller.import_certificate(SLOT[slot], cert)
                if is_private_key:
                    controller.import_key(SLOT[slot], private_key)
        return {'success': True, 'error': None}

    def _piv_verify_pin(self, piv_controller, pin=None):
        touch_required = False

        def touch_callback():
            nonlocal touch_required
            touch_required = True
            _touch_prompt()

        if pin:
            try:
                piv_controller.verify(pin, touch_callback=touch_callback)

            except AuthenticationBlocked as e:
                return {
                    'success': False,
                    'error_id': 'pin_blocked',
                }

            except WrongPin as e:
                return {
                    'success': False,
                    'error_id': 'wrong_pin',
                    'tries_left': e.tries_left,
                }

            except AuthenticationFailed as e:
                if touch_required:
                    return {
                        'success': False,
                        'error': 'wrong_key_or_touch_required',
                    }
                else:
                    return {
                        'success': False,
                        'error': 'wrong_key',
                        'message': 'Incorrect management key.',
                    }

            finally:
                if touch_required:
                    _close_touch_prompt()

        else:
            return {
                'success': False,
                'error_id': 'pin_required'
            }

    def _piv_ensure_authenticated(self, piv_controller, pin=None,
                                  mgm_key_hex=None):
        if piv_controller.has_protected_key:
            return self._piv_verify_pin(piv_controller, pin)
        else:
            touch_required = False

            def touch_callback():
                nonlocal touch_required
                touch_required = True
                _touch_prompt()

            if mgm_key_hex:
                if len(mgm_key_hex) != 48:
                    return {
                        'success': False,
                        'error_id': 'mgm_key_bad_format',
                    }

                try:
                    mgm_key_bytes = a2b_hex(mgm_key_hex)
                except Exception:
                    return {
                        'success': False,
                        'error_id': 'mgm_key_bad_format',
                    }

                try:
                    piv_controller.authenticate(
                        mgm_key_bytes,
                        touch_callback
                    )

                except AuthenticationFailed:
                    if touch_required:
                        return {
                            'success': False,
                            'error_id': 'wrong_mgm_key_or_touch_required',
                        }
                    else:
                        return {
                            'success': False,
                            'error_id': 'wrong_mgm_key'
                        }

                except BadFormat:
                    return {
                        'success': False,
                        'error_id': 'mgm_key_bad_format',
                    }

                finally:
                    if touch_required:
                        _close_touch_prompt()

            else:
                return {
                    'success': False,
                    'error_id': 'mgm_key_required'
                }

    def _piv_check_policies(self, piv_controller, pin_policy=None,
                            touch_policy=None):
        if pin_policy and not piv_controller.supports_pin_policies:
            return {
                'success': False,
                'error_id': 'unsupported_pin_policy',
                'supported_pin_policies': [],
            }

        if touch_policy and not (
                TOUCH_POLICY[touch_policy]
                in piv_controller.supported_touch_policies):
            return {
                'success': False,
                'error_id': 'unsupported_touch_policy',
                'supported_touch_policies': [
                    policy.name for policy in
                    piv_controller.supported_touch_policies
                ],
            }


controller = None


def _piv_serialise_cert(slot, cert):
    issuer_cns = cert.issuer.get_attributes_for_oid(x509.NameOID.COMMON_NAME)
    subject_cns = cert.subject.get_attributes_for_oid(x509.NameOID.COMMON_NAME)
    return {
        'slot': SLOT(slot).name,
        'issuedFrom': issuer_cns[0].value if issuer_cns else '',
        'issuedTo': subject_cns[0].value if subject_cns else '',
        'validFrom': cert.not_valid_before.date().isoformat(),
        'validTo': cert.not_valid_after.date().isoformat()
    }


def _touch_prompt():
    pyotherside.send('touchRequired')


def _close_touch_prompt():
    pyotherside.send('touchNotRequired')


def init_with_logging(log_level, log_file=None):
    logging_setup = as_json(ykman.logging_setup.setup)
    logging_setup(log_level, log_file)

    init()


def init():
    global controller
    controller = Controller()
    controller.refresh()
