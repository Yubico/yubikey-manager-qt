#!/usr/bin/env python
# -*- coding: utf-8 -*-


import datetime
import json
import logging
import os
import sys
import pyotherside
import struct
import types
import getpass
import urllib.parse
import ykman.logging_setup

from base64 import b32decode
from binascii import b2a_hex, a2b_hex
from fido2.ctap import CtapError
from cryptography import x509
from cryptography.hazmat.primitives import serialization
from ykman.descriptor import FailedOpeningDeviceException, get_descriptors
from ykman.device import device_config
from ykman.otp import OtpController
from ykman.fido import Fido2Controller
from ykman.driver_ccid import APDUError, SW
from ykman.driver_otp import YkpersError, libversion as ykpers_version
from ykman.piv import (
    PivController, ALGO, SLOT, AuthenticationBlocked,
    AuthenticationFailed, BadFormat, WrongPin, WrongPuk)
from ykman.scancodes import KEYBOARD_LAYOUT
from ykman.util import (
    APPLICATION, TRANSPORT, Mode, modhex_encode, modhex_decode,
    generate_static_pw, parse_certificates, get_leaf_certificates,
    parse_private_key)

logger = logging.getLogger(__name__)


def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped


def catch_error(f):
    def wrapped(*args, **kwargs):
        try:
            return f(*args, **kwargs)

        except YkpersError as e:
            if e.errno == 3:
                return failure('write error')
            if e.errno == 4:
                return failure('timeout')

            logger.error('Uncaught exception', exc_info=e)
            return unknown_failure(e)

        except FailedOpeningDeviceException:
            return failure('open_device_failed')

        except Exception as e:
            logger.error('Uncaught exception', exc_info=e)
            return unknown_failure(e)

    return wrapped


def success(result={}):
    result['success'] = True
    return result


def failure(err_id, result={}):
    result['success'] = False
    result['error_id'] = err_id
    return result


def unknown_failure(exception):
    return failure(None, {'error_message': str(exception)})


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
                    setattr(self, f, as_json(catch_error(func)))

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
            return failure('multiple_devices')
        desc = descriptors[0]

        # If we have a cached descriptor
        if self._descriptor:
            # Same device, return
            if desc.fingerprint == self._descriptor.fingerprint:
                return success({'dev': self._dev_info})

        self._descriptor = desc

        with self._open_device() as dev:
            if not dev:
                return failure('no_device')

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
            return success({'dev': self._dev_info})

    def write_config(self, usb_applications, nfc_applications, lock_code):
        usb_enabled = 0x00
        nfc_enabled = 0x00
        for app in usb_applications:
            usb_enabled |= APPLICATION[app]
        for app in nfc_applications:
            nfc_enabled |= APPLICATION[app]

        with self._open_device() as dev:

            if lock_code:
                lock_code = a2b_hex(lock_code)
                if len(lock_code) != 16:
                    return failure('lock_code_not_16_bytes')

            try:
                dev.write_config(
                    device_config(
                        usb_enabled=usb_enabled,
                        nfc_enabled=nfc_enabled,
                        ),
                    reboot=True,
                    lock_key=lock_code)
            except APDUError as e:
                if (e.sw == SW.VERIFY_FAIL_NO_RETRY):
                    return failure('wrong_lock_code')
                raise

            return success()

    def refresh_piv(self):
        with self._open_piv() as piv_controller:
            return success({
                'piv_data': {
                    'certs': self._piv_list_certificates(piv_controller),
                    'has_derived_key': piv_controller.has_derived_key,
                    'has_protected_key': piv_controller.has_protected_key,
                    'has_stored_key': piv_controller.has_stored_key,
                    'pin_tries': piv_controller.get_pin_tries(),
                    'puk_blocked': piv_controller.puk_blocked,
                    'supported_algorithms':
                        [a.name for a in piv_controller.supported_algorithms],
                },
            })

    def set_mode(self, interfaces):
        with self._open_device() as dev:
            transports = sum([TRANSPORT[i] for i in interfaces])
            dev.mode = Mode(transports & TRANSPORT.usb_transports())
        return success()

    def get_username(self):
        username = getpass.getuser()
        return success({'username': username})

    def is_macos(self):
        return success({'is_macos': sys.platform == 'darwin'})

    def slots_status(self):
        with self._open_otp_controller() as controller:
            return success({'status': controller.slot_status})

    def erase_slot(self, slot):
        with self._open_otp_controller() as controller:
            controller.zap_slot(slot)
        return success()

    def swap_slots(self):
        with self._open_otp_controller() as controller:
            controller.swap_slots()
        return success()

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
        key = a2b_hex(key)
        public_id = modhex_decode(public_id)
        private_id = a2b_hex(private_id)
        with self._open_otp_controller() as controller:
            controller.program_otp(slot, key, public_id, private_id)
        return success()

    def program_challenge_response(self, slot, key, touch):
        key = a2b_hex(key)
        with self._open_otp_controller() as controller:
            controller.program_chalresp(slot, key, touch)
        return success()

    def program_static_password(self, slot, key, keyboard_layout):
        with self._open_otp_controller() as controller:
            controller.program_static(
                slot, key,
                keyboard_layout=KEYBOARD_LAYOUT[keyboard_layout])
        return success()

    def program_oath_hotp(self, slot, key, digits):
        unpadded = key.upper().rstrip('=').replace(' ', '')
        key = b32decode(unpadded + '=' * (-len(unpadded) % 8))
        with self._open_otp_controller() as controller:
            controller.program_hotp(slot, key, hotp8=(int(digits) == 8))
        return success()

    def fido_has_pin(self):
        with self._open_fido2_controller() as controller:
            return success({'hasPin': controller.has_pin})

    def fido_pin_retries(self):
        try:
            with self._open_fido2_controller() as controller:
                return success({'retries': controller.get_pin_retries()})
        except CtapError as e:
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return failure('PIN authentication is currently blocked. '
                               'Remove and re-insert the YubiKey.')
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return failure('PIN is blocked.')
            raise

    def fido_set_pin(self, new_pin):
        try:
            with self._open_fido2_controller() as controller:
                controller.set_pin(new_pin)
                return success()
        except CtapError as e:
            if e.code == CtapError.ERR.INVALID_LENGTH or \
                    e.code == CtapError.ERR.PIN_POLICY_VIOLATION:
                return failure('too long')
            raise

    def fido_change_pin(self, current_pin, new_pin):
        try:
            with self._open_fido2_controller() as controller:
                controller.change_pin(old_pin=current_pin, new_pin=new_pin)
                return success()
        except CtapError as e:
            if e.code == CtapError.ERR.INVALID_LENGTH or \
                    e.code == CtapError.ERR.PIN_POLICY_VIOLATION:
                return failure('too long')
            if e.code == CtapError.ERR.PIN_INVALID:
                return failure('wrong pin')
            if e.code == CtapError.ERR.PIN_AUTH_BLOCKED:
                return failure('currently blocked')
            if e.code == CtapError.ERR.PIN_BLOCKED:
                return failure('blocked')
            raise

    def fido_reset(self):
        try:
            with self._open_fido2_controller() as controller:
                controller.reset()
                return success()
        except CtapError as e:
            if e.code == CtapError.ERR.NOT_ALLOWED:
                return failure('not allowed')
            if e.code == CtapError.ERR.ACTION_TIMEOUT:
                return failure('touch timeout')
            raise

    def piv_reset(self):
        with self._open_piv() as controller:
            controller.reset()
            return success()

    def _piv_list_certificates(self, controller):
        return {
            SLOT(slot).name: _piv_serialise_cert(slot, cert) for slot, cert in controller.list_certificates().items()  # noqa: E501
        }

    def piv_delete_certificate(self, slot_name, pin=None, mgm_key_hex=None):
        logger.debug('piv_delete_certificate %s', slot_name)

        with self._open_piv() as piv_controller:
            auth_failed = self._piv_ensure_authenticated(
                piv_controller, pin=pin, mgm_key_hex=mgm_key_hex)
            if auth_failed:
                return auth_failed

            piv_controller.delete_certificate(SLOT[slot_name])
            return success()

    def piv_generate_certificate(
            self, slot_name, algorithm, common_name, expiration_date,
            self_sign=True, csr_file_url=None, pin=None, mgm_key_hex=None):
        logger.debug('slot_name=%s algorithm=%s common_name=%s '
                     'expiration_date=%s self_sign=%s csr_file_url=%s',
                     slot_name, algorithm, common_name, expiration_date,
                     self_sign, csr_file_url)

        if csr_file_url:
            file_path = urllib.parse.urlparse(csr_file_url).path
            file_path_windows = file_path[1:]
            if os.name == 'nt':
                file_path = file_path_windows

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
                    return failure(
                        'invalid_iso8601_date',
                        {'date': expiration_date})

            public_key = piv_controller.generate_key(
                SLOT[slot_name], ALGO[algorithm])

            pin_failed = self._piv_verify_pin(piv_controller, pin)
            if pin_failed:
                return pin_failed

            try:
                if self_sign:
                    piv_controller.generate_self_signed_certificate(
                        SLOT[slot_name], public_key, common_name, now,
                        valid_to)

                else:
                    csr = piv_controller.generate_certificate_signing_request(
                        SLOT[slot_name], public_key, common_name)

                    with open(file_path, 'w+b') as csr_file:
                        csr_file.write(csr.public_bytes(
                            encoding=serialization.Encoding.PEM))

            except APDUError as e:
                if e.sw == SW.SECURITY_CONDITION_NOT_SATISFIED:
                    return failure('pin_required')
                raise

            return success()

    def piv_change_pin(self, old_pin, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.change_pin(old_pin, new_pin)
                logger.debug('PIN change successful!')
                return success()

            except AuthenticationBlocked:
                return failure('pin_blocked')

            except WrongPin as e:
                return failure('wrong_pin', {'tries_left': e.tries_left})

            except APDUError as e:
                if e.sw == SW.INCORRECT_PARAMETERS:
                    return failure('incorrect_parameters')

                tries_left = piv_controller.get_pin_tries()
                logger.debug('PIN change failed. %s tries left.',
                             tries_left, exc_info=e)
                return {
                    'success': False,
                    'tries_left': tries_left,
                }

    def piv_change_puk(self, old_puk, new_puk):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.change_puk(old_puk, new_puk)
                return success()

            except AuthenticationBlocked:
                return failure('puk_blocked')

            except WrongPuk as e:
                return failure('wrong_puk', {'tries_left': e.tries_left})

    def piv_generate_random_mgm_key(self):
        return b2a_hex(ykman.piv.generate_random_management_key()).decode(
            'utf-8')

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
                return failure('new_mgm_key_bad_hex')

            if new_key is not None and len(new_key) != 24:
                logger.debug('Wrong length for new management key: %d',
                             len(new_key))
                return failure('new_mgm_key_bad_length')

            piv_controller.set_mgm_key(
                new_key, touch=False, store_on_device=store_on_device)
            return success()

    def piv_unblock_pin(self, puk, new_pin):
        with self._open_piv() as piv_controller:
            try:
                piv_controller.unblock_pin(puk, new_pin)
                return success()

            except AuthenticationBlocked:
                return failure('puk_blocked')

            except WrongPuk as e:
                return failure('wrong_puk', {'tries_left': e.tries_left})

    def piv_can_parse(self, file_url):
        file_path = urllib.parse.urlparse(file_url).path
        with open(file_path, 'r+b') as file:
            data = file.read()
            try:
                parse_certificates(data, password=None)
                return success()
            except (ValueError, TypeError):
                pass
            try:
                parse_private_key(data, password=None)
                return success()
            except (ValueError, TypeError):
                pass
        raise ValueError('Failed to parse certificate or key')

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
                certs = parse_certificates(data, password)
                if len(certs) > 0:
                    is_cert = True
            except (ValueError, TypeError):
                pass
            try:
                private_key = parse_private_key(data, password)
                is_private_key = True
            except (ValueError, TypeError):
                pass

            if not (is_cert or is_private_key):
                return failure('failed_parsing')

            with self._open_piv() as controller:
                auth_failed = self._piv_ensure_authenticated(
                    controller, pin, mgm_key)
                if auth_failed:
                    return auth_failed
                if is_private_key:
                    controller.import_key(SLOT[slot], private_key)
                if is_cert:
                    if len(certs) > 1:
                        leafs = get_leaf_certificates(certs)
                        cert_to_import = leafs[0]
                    else:
                        cert_to_import = certs[0]

                    controller.import_certificate(
                            SLOT[slot], cert_to_import)
        return success({
            'imported_cert': is_cert,
            'imported_key': is_private_key
        })

    def piv_export_certificate(self, slot, file_url):
        file_path = urllib.parse.urlparse(file_url).path
        file_path_windows = file_path[1:]
        if os.name == 'nt':
            file_path = file_path_windows
        with self._open_piv() as controller:
            cert = controller.read_certificate(SLOT[slot])
            with open(file_path, 'wb') as file:
                file.write(
                    cert.public_bytes(
                        encoding=serialization.Encoding.PEM))
        return success()

    def _piv_verify_pin(self, piv_controller, pin=None):
        touch_required = False

        def touch_callback():
            nonlocal touch_required
            touch_required = True
            _touch_prompt()

        if pin:
            try:
                piv_controller.verify(pin, touch_callback=touch_callback)

            except AuthenticationBlocked:
                return failure('pin_blocked')

            except WrongPin as e:
                return failure(
                    'wrong_pin',
                    {'tries_left': e.tries_left})

            except AuthenticationFailed:
                if touch_required:
                    return failure('wrong_mgm_key_or_touch_required')
                else:
                    return failure('wrong_mgm_key')

            finally:
                if touch_required:
                    _close_touch_prompt()

        else:
            return failure('pin_required')

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
                    return failure('mgm_key_bad_format')

                try:
                    mgm_key_bytes = a2b_hex(mgm_key_hex)
                except Exception:
                    return failure('mgm_key_bad_format')

                try:
                    piv_controller.authenticate(
                        mgm_key_bytes,
                        touch_callback
                    )

                except AuthenticationFailed:
                    if touch_required:
                        return failure('wrong_mgm_key_or_touch_required')
                    else:
                        return failure('wrong_mgm_key')

                except BadFormat:
                    return failure('mgm_key_bad_format')

                finally:
                    if touch_required:
                        _close_touch_prompt()

            else:
                return failure('mgm_key_required')


controller = None


def _piv_serialise_cert(slot, cert):
    # Try reading out issuer and subject,
    # may throw ValueError if malformed
    malformed = False
    try:
        issuer_cns = cert.issuer.get_attributes_for_oid(
            x509.NameOID.COMMON_NAME)
    except ValueError:
        malformed = True
        issuer_cns = None
    try:
        subject_cns = cert.subject.get_attributes_for_oid(
            x509.NameOID.COMMON_NAME)
    except ValueError:
        malformed = True
        subject_cns = None
    return {
        'slot': SLOT(slot).name,
        'malformed': malformed,
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
