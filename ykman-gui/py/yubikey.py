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
from binascii import b2a_hex, a2b_hex, Error
from cryptography import x509
from cryptography.hazmat.primitives import serialization

from ykman.descriptor import get_descriptors
from ykman.driver import ModeSwitchError
from ykman.driver_ccid import APDUError
from ykman.driver_otp import YkpersError
from ykman.opgp import OpgpController, KEY_SLOT
from ykman.piv import (ALGO, PIN_POLICY, PivController, SLOT, SW, TOUCH_POLICY)
from ykman.util import (
    CAPABILITY, TRANSPORT, Mode, modhex_encode, modhex_decode,
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
                    'enabled': [c.name for c in CAPABILITY if c & dev.enabled],
                    'capabilities': [
                        c.name for c in CAPABILITY if c & dev.capabilities],
                    'connections': [
                        t.name for t in TRANSPORT if t & dev.capabilities
                    ],
                    'piv': {}
                }

        with self._open_piv() as piv_controller:
            if self._dev_info:
                piv_certificates = self._piv_list_certificates()

                self._dev_info['piv'] = {
                    'version': '.'.join(str(x) for x in self._piv_version()),
                    'certificates': piv_certificates,
                    'has_protected_key': piv_controller.has_protected_key
                }

        return self._dev_info

    def set_mode(self, connections):
        logger.debug('connections: %s', connections)

        with self._open_device() as dev:
            logger.debug('dev: %s', dev)

            try:
                transports = sum([TRANSPORT[c] for c in connections])
                dev.mode = Mode(transports & TRANSPORT.usb_transports())
            except ModeSwitchError as e:
                logger.error('Failed to set modes', exc_info=e)
                return str(e)

    def slots_status(self):
        with self._open_device(TRANSPORT.OTP) as dev:
            return dev.driver.slot_status

    def erase_slot(self, slot):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.zap_slot(slot)
        except YkpersError as e:
            return e.errno

    def swap_slots(self):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.swap_slots()
        except YkpersError as e:
            return e.errno

    def serial_modhex(self):
        with self._open_device(TRANSPORT.OTP) as dev:
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
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.program_otp(slot, key, public_id, private_id)
        except YkpersError as e:
            return e.errno

    def program_challenge_response(self, slot, key, touch):
        try:
            key = a2b_hex(key)
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.program_chalresp(slot, key, touch)
        except YkpersError as e:
            return e.errno

    def program_static_password(self, slot, key):
        try:
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.program_static(slot, key)
        except YkpersError as e:
            return e.errno

    def program_oath_hotp(self, slot, key, digits):
        try:
            unpadded = key.upper().rstrip('=').replace(' ', '')
            key = b32decode(unpadded + '=' * (-len(unpadded) % 8))
            with self._open_device(TRANSPORT.OTP) as dev:
                dev.driver.program_hotp(slot, key, hotp8=(digits == 8))
        except Error as e:
            return str(e)
        except YkpersError as e:
            return e.errno

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

    def piv_reset(self):
        try:
            with self._open_device(TRANSPORT.CCID) as dev:
                controller = PivController(dev.driver)
                controller.reset()
                return True

        except Exception as e:
            logger.error('Failed to reset PIV applet', exc_info=e)
            return False

    def _piv_version(self):
        with self._open_piv() as piv_controller:
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
                except Exception as e:
                    logger.error(
                        'Management key authentication failed',
                        exc_info=e)
                    return {
                        'success': False,
                        'message': str(e),
                        'failure': {'keyAuthentication': True}
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
                return (True, None)
            except Exception as e:
                retries = piv_controller.get_pin_tries()
                logger.debug('PIN change failed. %s retries left.',
                             retries, exc_info=e)
                return (False, retries)

    def piv_change_puk(self, old_puk, new_puk):
        with self._open_piv() as piv_controller:
            result = piv_controller.change_puk(old_puk, new_puk)
            logger.debug('PUK change result: %s', result)
            return result

    def _piv_list_certificates(self):
        with self._open_piv() as piv_controller:
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

            if pin_policy and not (
                    PIN_POLICY[pin_policy]
                    in piv_controller.supported_pin_policies):
                return {
                    'success': False,
                    'failure': {
                        'supportedPinPolicies': [
                            policy.name for policy in
                            piv_controller.supported_pin_policies],
                    }
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

            try:
                piv_controller.import_key(SLOT[slot_name], private_key,
                                          pin_policy, touch_policy)
                return {'success': True}
            except Exception as e:
                logger.error('Failed to import certificate', exc_info=e)
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

                public_key = piv_controller.generate_key(
                    SLOT[slot_name], ALGO[algorithm],
                    pin_policy=pin_policy or PIN_POLICY.DEFAULT,
                    touch_policy=(TOUCH_POLICY.from_string(touch_policy)
                                  if touch_policy else TOUCH_POLICY.DEFAULT))

                if self_sign:
                    piv_controller.generate_self_signed_certificate(
                        SLOT[slot_name], public_key, common_name, now,
                        valid_to)
                else:
                    csr = piv_controller.generate_certificate_signing_request(
                        SLOT[slot_name], public_key, common_name)
                    try:
                        with open(file_path, 'w+b') as csr_file:
                            csr_file.write(csr.public_bytes(
                                encoding=serialization.Encoding.PEM))
                    except PermissionError as e:
                        logger.debug('Cannot write CSR file to %s',
                                     csr_file_url, exc_info=e)
                        return {
                            'success': False,
                            'message': str(e),
                            'failure': {'permissionDenied': True},
                        }
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


def init():
    global controller
    controller = Controller()
    controller.refresh()


def init_with_logging(log_level, log_file=None):
    logging_setup = as_json(ykman.logging_setup.setup)
    logging_setup(log_level, log_file)

    init()
