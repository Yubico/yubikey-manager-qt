#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
#os.environ['PYUSB_DEBUG'] = 'debug'

from ykman.device import open_device
from ykman.util import CAPABILITY, TRANSPORT, list_yubikeys, Mode

NON_FEATURE_CAPABILITIES = [CAPABILITY.CCID, CAPABILITY.NFC]

import ctypes.util
def find_library(libname):
    if os.path.isfile(libname):
        return libname
    return ctypes.util.find_library(libname)

import usb.backend.libusb1
backend = usb.backend.libusb1.get_backend(find_library=find_library)

def get_features():
    return [c.name for c in CAPABILITY if c not in NON_FEATURE_CAPABILITIES]

def count_devices():
    return len(list_yubikeys())

def refresh():
    dev = open_device()
    if dev:
        return {
            'name': dev.device_name,
            'version': '.'.join(str(x) for x in dev.version),
            'serial': dev.serial,
            'enabled': [c.name for c in CAPABILITY if c & dev.enabled],
            'connections': [t.name for t in TRANSPORT if t & dev.capabilities]
        }

def set_mode(connections):
    dev = open_device()
    try:
        transports = sum([TRANSPORT[c] for c in connections])
        dev.mode = Mode(transports & TRANSPORT.usb_transports())
    except Exception as e:
        return str(e)
    return None

def slots_status():
    dev = open_device(TRANSPORT.OTP)
    return dev.driver.slot_status
