#!/usr/bin/env python
# -*- coding: utf-8 -*-


import datetime
import json
import logging
import os
import struct
import types
import urllib.parse
import ykman.logging_setup

from base64 import b32decode
from binascii import b2a_hex, a2b_hex
from cryptography import x509
from cryptography.hazmat.primitives import serialization
from fido2.ctap import CtapError

from ykman.descriptor import get_descriptors
from ykman.driver_ccid import APDUError
from ykman.driver_otp import YkpersError
from ykman.otp import OtpController
from ykman.opgp import OpgpController, KEY_SLOT
from ykman.fido import Fido2Controller
from ykman.piv import (ALGO, PIN_POLICY, PivController, SLOT, SW, TOUCH_POLICY)
from ykman.scancodes import KEYBOARD_LAYOUT
from ykman.util import (
    APPLICATION, TRANSPORT, Mode, modhex_encode, modhex_decode,
    generate_static_pw, parse_certificate, parse_private_key)

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
            return

        desc = descriptors[0]
        if desc.fingerprint != (
                self._descriptor.fingerprint if self._descriptor else None):
            self._descriptor = desc

            with self._open_device() as dev:
                if not dev:
                    return

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
                    'usb_interfaces_enabled': str(dev.mode).split('+'),
                    'can_write_config': dev.can_write_config,
                    'piv': {},
                }
        return self._dev_info

    def refresh_piv(self):
        with self._open_piv() as piv_controller:
            piv_certificates = self._piv_list_certificates(piv_controller)

            return {
                'version': '.'.join(
                    str(x) for x in self._piv_version(piv_controller)),
                'certificates': piv_certificates,
                'has_protected_key': piv_controller.has_protected_key,
                'pin_tries': piv_controller.get_pin_tries(),
                'supported_touch_policies': [
                    policy.name for policy in
                    piv_controller.supported_touch_policies],
                'supports_pin_policies': piv_controller.supports_pin_policies,  # noqa: E501
            }

    def set_mode(self, interfaces):
        with self._open_device() as dev:
            try:
                transports = sum([TRANSPORT[i] for i in interfaces])
                dev.mode = Mode(transports & TRANSPORT.usb_transports())
            except Exception as e:
                logger.error('Failed to set mode', exc_info=e)
                return str(e)

    def slots_status(self):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                return controller.slot_status
        except Exception as e:
            logger.error('Failed to read slot status', exc_info=e)

    def erase_slot(self, slot):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.zap_slot(slot)
        except YkpersError as e:
            return e.errno

    def swap_slots(self):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.swap_slots()
        except YkpersError as e:
            return e.errno

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
        except YkpersError as e:
            return e.errno

    def program_challenge_response(self, slot, key, touch):
        try:
            key = a2b_hex(key)
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_chalresp(slot, key, touch)
        except YkpersError as e:
            return e.errno

    def program_static_password(self, slot, key, keyboard_layout):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                controller = OtpController(dev.driver)
                controller.program_static(
                    slot, key,
                    keyboard_layout=KEYBOARD_LAYOUT[keyboard_layout])
        except YkpersError as e:
            return e.errno

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

    def openpgp_reset(self):
        try:
            with self._open_device(TRANSPORT.CCID) as dev:
                controller = OpgpController(dev.driver)
                controller.reset()
                return True
        except Exception as e:
            logger.error('Failed to reset OpenPGP applet', exc_info=e)
            return False

    def openpgp_get_touch(self):
        try:
            with self._open_device(TRANSPORT.CCID) as dev:
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
            with self._open_device(TRANSPORT.CCID) as dev:
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
            with self._open_device(TRANSPORT.CCID) as dev:
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
            with self._open_device(TRANSPORT.CCID) as dev:
                controller = OpgpController(dev.driver)
                return controller.version
        except Exception as e:
            logger.error('Failed to get OpenPGP applet version', exc_info=e)
            return None

    def openpgp_get_remaining_pin_retries(self):
        try:
            with self._open_device(TRANSPORT.CCID) as dev:
                controller = OpgpController(dev.driver)
                return controller.get_remaining_pin_tries()
        except Exception as e:
            logger.error('Failed to get remaining OpenPGP PIN retries',
                         exc_info=e)
            return None

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
                return {'success': False,
                        'error': 'Too long PIN, maximum size is 128 bytes.'}
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
                        'error': 'Too long PIN, maximum size is 128 bytes.'}
            if e.code == CtapError.ERR.PIN_INVALID:
                return {'success': False,
                        'error': 'The current PIN is wrong.'}
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return {'success': False,
                        'error': 'PIN authentication is currently blocked. '
                        'Remove and re-insert the YubiKey.'}
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return {'success': False, 'error': 'PIN is blocked.'}
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
                return {'success': False, 'error': 'Not allowed'}
            if e.code == CtapError.ERR.ACTION_TIMEOUT:
                return {'success': False, 'error': 'Touch timeout'}
            else:
                logger.error('Reset throwed an exception', exc_info=e)
                return {'success': False, 'error': str(e)}
        except Exception as e:
            logger.error('Reset throwed an exception', exc_info=e)
            return {'success': False, 'error': str(e)}

    def piv_reset(self):
        try:
            with self._open_device(TRANSPORT.CCID) as dev:
                controller = PivController(dev.driver)
                controller.reset()
                return True

        except Exception as e:
            logger.error('Failed to reset PIV applet', exc_info=e)
            return False

    def _piv_version(self, piv_controller):
        try:
            return piv_controller.version
        except AttributeError:
            return None

    def _piv_verify_pin(self, piv_controller, pin=None):
        if pin:
            try:
                piv_controller.verify(pin)
            except Exception as e:
                logger.error('PIN verification failed', exc_info=e)
                return {
                    'success': False,
                    'message': str(e),
                    'failure': {'pinVerification': True}
                }
        else:
            return {
                'success': False,
                'failure': {'pinRequired': True},
            }

    def _piv_ensure_authenticated(self, piv_controller, pin=None,
                                  mgm_key_hex=None):
        if piv_controller.has_protected_key:
            return self._piv_verify_pin(piv_controller, pin)
        else:
            if mgm_key_hex:
                try:
                    piv_controller.authenticate(a2b_hex(mgm_key_hex))
                except APDUError as e:
                    return {
                        'success': False,
                        'failure': {'keyAuthentication': True}
                    }
                except Exception as e:
                    logger.debug('Failed to parse management key', exc_info=e)
                    return {
                        'success': False,
                        'message': str(e),
                        'failure': {'parseKey': True}
                    }
            else:
                return {
                    'success': False,
                    'failure': {'keyRequired': True},
                }

    def piv_change_pin(self, old_pin, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.change_pin(old_pin, new_pin)
                logger.debug('PIN change successful!')
                return {'success': True}
            except Exception as e:
                tries_left = piv_controller.get_pin_tries()
                logger.debug('PIN change failed. %s tries left.',
                             tries_left, exc_info=e)
                return {
                    'success': False,
                    'tries_left': tries_left,
                }

    def piv_change_puk(self, old_puk, new_puk):
        with self._open_piv() as piv_controller:
            result = piv_controller.change_puk(old_puk, new_puk)
            logger.debug('PUK change result: %s', result)
            return {
                'success': result.success,
                'tries_left': result.tries_left,
              }

    def _piv_check_policies(self, piv_controller, pin_policy=None,
                            touch_policy=None):
        if pin_policy and not piv_controller.supports_pin_policies:
            return {
                'success': False,
                'failure': {'supportedPinPolicies': []}
            }

        if touch_policy and not (
                TOUCH_POLICY[touch_policy]
                in piv_controller.supported_touch_policies):
            return {
                'success': False,
                'failure': {
                    'supportedTouchPolicies': [
                        policy.name for policy in
                        piv_controller.supported_touch_policies],
                }
            }

    def _piv_list_certificates(self, piv_controller):
        certs = piv_controller.list_certificates()
        logger.debug('Certificates: %s', certs)
        certs = {
            SLOT(slot).name: toDict(cert) for slot, cert in certs.items()}
        logger.debug('Certificates: %s', certs)
        return certs

    def piv_generate_random_mgm_key(self):
        return b2a_hex(ykman.piv.generate_random_management_key()).decode(
            'utf-8')

    def piv_change_mgm_key(self, pin, current_key_hex, new_key_hex,
                           touch=False, store_on_device=False):
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
                    'message': str(e),
                    'failure': {'parseNewKey': True},
                  }

            if new_key is not None and len(new_key) != 24:
                logger.debug('Wrong length for new management key: %d',
                             len(new_key))
                return {
                    'success': False,
                    'failure': {'newKeyLength': True},
                }

            try:
                piv_controller.set_mgm_key(new_key, touch, store_on_device)
                return {'success': True}
            except Exception as e:
                logger.error('Failed to change management key', exc_info=e)
                return {
                    'success': False,
                    'message': str(e),
                    'failure': {'setKey': True},
                }

    def piv_export_certificate(self, slot_name, file_url):
        logger.debug('piv_export_certificate %s %s', slot_name, file_url)

        file_path = urllib.parse.urlparse(file_url).path

        with self._open_piv() as piv_controller:
            try:
                cert = piv_controller.read_certificate(SLOT[slot_name])
            except APDUError as e:
                if e.sw == SW.NOT_FOUND:
                    return {
                        'success': False,
                        'failure': {
                            'notFound': True,
                        },
                    }
                else:
                    logger.error('Failed to read certificate from slot %s',
                                 slot_name, exc_info=e)
                    return {
                        'success': False,
                        'message': 'Failed to read certificate from slot %s' %
                        slot_name,
                        'failure': {},
                    }

            with open(file_path, 'w+b') as certificate_file:
                certificate_file.write(cert.public_bytes(
                    encoding=serialization.Encoding.PEM))

            return {'success': True}

    def piv_import_certificate(self, slot_name, file_url, pin=None,
                               mgm_key_hex=None, password=None):
        logger.debug('piv_import_certificate %s %s', slot_name, file_url)

        file_path = urllib.parse.urlparse(file_url).path

        with self._open_piv() as piv_controller:
            with open(file_path, 'r+b') as certificate_file:
                data = certificate_file.read()

            if password is not None:
                password = password.encode('utf-8')
            try:
                cert = parse_certificate(data, password)
            except (ValueError, TypeError):
                if password is None:
                    return {
                        'success': False,
                        'failure': {'passwordRequired': True},
                    }
                else:
                    return {
                        'success': False,
                        'failure': {'wrongPassword': True},
                    }

            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
            if auth_failed:
                return auth_failed

            try:
                piv_controller.import_certificate(SLOT[slot_name], cert)
                return {'success': True}
            except Exception as e:
                logger.error('Failed to import certificate', exc_info=e)
                return {
                    'success': False,
                    'failure': {'import': True},
                }

    def piv_import_key(self, slot_name, file_url, pin=None, mgm_key_hex=None,
                       password=None, pin_policy=None, touch_policy=None):
        logger.debug('piv_import_key %s %s', slot_name, file_url)

        file_path = urllib.parse.urlparse(file_url).path

        with self._open_piv() as piv_controller:
            with open(file_path, 'r+b') as key_file:
                data = key_file.read()

            if password is not None:
                password = password.encode('utf-8')
            try:
                private_key = parse_private_key(data, password)
            except (ValueError, TypeError):
                if password is None:
                    return {
                        'success': False,
                        'failure': {'passwordRequired': True},
                    }
                else:
                    return {
                        'success': False,
                        'failure': {'wrongPassword': True},
                    }

            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
            if auth_failed:
                return auth_failed

            unsupported_policy = self._piv_check_policies(
                piv_controller, pin_policy=pin_policy,
                touch_policy=touch_policy)
            if unsupported_policy:
                return unsupported_policy

            try:
                piv_controller.import_key(
                    SLOT[slot_name], private_key,
                    pin_policy=(PIN_POLICY.from_string(pin_policy)
                                if pin_policy else PIN_POLICY.DEFAULT),
                    touch_policy=(TOUCH_POLICY.from_string(touch_policy)
                                  if touch_policy else TOUCH_POLICY.DEFAULT))
                return {'success': True}
            except Exception as e:
                logger.error('Failed to import key', exc_info=e)
                return {
                    'success': False,
                    'message': str(e),
                    'failure': {'import': True},
                }

            data = private_key.read()

    def piv_delete_certificate(self, slot_name, pin=None, mgm_key_hex=None):
        logger.debug('piv_delete_certificate %s', slot_name)

        with self._open_piv() as piv_controller:
            try:
                auth_failed = self._piv_ensure_authenticated(
                    piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
                if auth_failed:
                    return auth_failed

                piv_controller.delete_certificate(SLOT[slot_name])
                return {'success': True}
            except APDUError as e:
                logger.error('Failed', exc_info=e)
                return {'success': False}

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
            try:
                auth_failed = self._piv_ensure_authenticated(
                    piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
                if auth_failed:
                    return auth_failed

                now = datetime.datetime.now()
                try:
                    year = int(expiration_date[0:4])
                    month = int(expiration_date[(4+1):(4+1+2)])
                    day = int(expiration_date[(4+1+2+1):(4+1+2+1+2)])
                    valid_to = datetime.datetime(year, month, day)
                except ValueError as e:
                    logger.debug('Failed to parse date: ' + expiration_date,
                                 exc_info=e)
                    return {
                        'success': False,
                        'message': 'Invalid date: ' + expiration_date,
                        'failure': {'invalidDate': True},
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

                if pin:
                    pin_failed = self._piv_verify_pin(piv_controller, pin)
                    if pin_failed:
                        return pin_failed

                if self_sign:
                    try:
                        piv_controller.generate_self_signed_certificate(
                            SLOT[slot_name], public_key, common_name, now,
                            valid_to)
                    except APDUError as e:
                        if e.sw == SW.ACCESS_DENIED:
                            return {
                                'success': False,
                                'failure': {'pinRequired': True}
                            }
                        else:
                            logger.error(
                                'Failed to generate self signed certificate',
                                exc_info=e)
                            return {
                                'success': False,
                                'message': str(e),
                                'failure': {'unknown': True}
                            }
                else:
                    csr = piv_controller.generate_certificate_signing_request(
                        SLOT[slot_name], public_key, common_name)
                    try:
                        with open(file_path, 'w+b') as csr_file:
                            csr_file.write(csr.public_bytes(
                                encoding=serialization.Encoding.PEM))
                    except Exception as e:
                        logger.error('Failed to write CSR file to %s',
                                     csr_file_url, exc_info=e)
                        return {
                            'success': False,
                            'message': str(e),
                            'failure': {'writeFile': True},
                        }

                return {'success': True}
            except APDUError as e:
                logger.error('Failed', exc_info=e)
                return {'success': False}

    def piv_unblock_pin(self, puk, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.unblock_pin(puk, new_pin)
                return {
                    'success': True,
                    'pin_tries': piv_controller.get_pin_tries(),
                }
            except ValueError as e:
                return {
                    'success': False,
                    'message': str(e),
                }


def toDict(cert):
    return {
        'subject': {
            'commonName': cert.subject.get_attributes_for_oid(x509.NameOID.COMMON_NAME)[0].value,  # noqa: E501
        },
        'issuer': {
            'commonName': cert.issuer.get_attributes_for_oid(x509.NameOID.COMMON_NAME)[0].value,  # noqa: E501
        },
        'validity': {
            'from': cert.not_valid_before.isoformat(),
            'to': cert.not_valid_after.isoformat(),
        }
    }


controller = None


def init_with_logging(log_level, log_file=None):
    logging_setup = as_json(ykman.logging_setup.setup)
    logging_setup(log_level, log_file)

    init()


def init():
    global controller
    controller = Controller()
    controller.refresh()
