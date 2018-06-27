import QtQuick 2.0
import io.thp.pyotherside 1.4
import "utils.js" as Utils


// @disable-check M300
Python {
    id: py

    property int nDevices
    property bool hasDevice
    property string name
    property string version
    property string serial
    property bool canWriteConfig
    property var supportedUsbInterfaces: []
    property var enabledUsbInterfaces: []
    property var supportedUsbApplications: []
    property var enabledUsbApplications: []
    property bool yubikeyModuleLoaded: false
    property bool yubikeyReady: false
    property var queue: []

    signal enableLogging(string logLevel, string logFile)
    signal disableLogging

    Component.onCompleted: {
        importModule('site', function () {
            call('site.addsitedir', [appDir + '/pymodules'], function () {
                addImportPath(urlPrefix + '/py')

                importModule('yubikey', function () {
                    yubikeyModuleLoaded = true
                })
            })
        })
    }

    onEnableLogging: {
        do_call('yubikey.init_with_logging',
                [logLevel || 'DEBUG', logFile || null], function () {
                    yubikeyReady = true
                })
    }
    onDisableLogging: {
        do_call('yubikey.init', [], function () {
            yubikeyReady = true
        })
    }

    onYubikeyModuleLoadedChanged: runQueue()
    onYubikeyReadyChanged: runQueue()

    onError: handleErrors(traceback)

    function handleErrors(traceback) {
        if (Utils.includes(traceback, 'KeyboardInterrupt')) {
            Qt.quit()
        } else {
            console.log(traceback)
        }
    }

    function isPythonReady(funcName) {
        if (Utils.startsWith(funcName, "yubikey.init")) {
            return yubikeyModuleLoaded
        } else {
            return yubikeyReady
        }
    }

    function runQueue() {
        var oldQueue = queue
        queue = []
        for (var i in oldQueue) {
            do_call(oldQueue[i][0], oldQueue[i][1], oldQueue[i][2])
        }
    }

    function do_call(func, args, cb) {
        if (!isPythonReady(func)) {
            queue.push([func, args, cb])
        } else {
            call(func, args, function (json) {
                if (cb) {
                    cb(json ? JSON.parse(json) : undefined)
                }
            })
        }
    }

    function refresh(doneCallback) {
        do_call('yubikey.controller.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                do_call('yubikey.controller.refresh', [], function (dev) {
                    hasDevice = dev !== undefined && dev !== null
                    name = dev ? dev.name : ''
                    version = dev ? dev.version : ''
                    serial = dev ? dev.serial : ''
                    supportedUsbApplications = dev ? dev.usb_supported : []
                    enabledUsbApplications = dev ? dev.usb_enabled : []
                    supportedUsbInterfaces = dev ? dev.usb_interfaces_supported : []
                    enabledUsbInterfaces = dev ? dev.usb_interfaces_enabled : []
                    canWriteConfig = dev ? dev.can_write_config : []
                })
            } else if (hasDevice) {
                hasDevice = false
            }

            if (doneCallback) {
                doneCallback()
            }
        })
    }

    function set_mode(connections, cb) {
        do_call('yubikey.controller.set_mode', [connections], cb)
    }

    function slots_status(cb) {
        do_call('yubikey.controller.slots_status', [], cb)
    }

    function erase_slot(slot, cb) {
        do_call('yubikey.controller.erase_slot', [slot], cb)
    }

    function swap_slots(cb) {
        do_call('yubikey.controller.swap_slots', [], cb)
    }

    function serial_modhex(cb) {
        do_call('yubikey.controller.serial_modhex', [], cb)
    }

    function random_uid(cb) {
        do_call('yubikey.controller.random_uid', [], cb)
    }

    function random_key(bytes, cb) {
        do_call('yubikey.controller.random_key', [bytes], cb)
    }

    function generate_static_pw(keyboard_layout, cb) {
        do_call('yubikey.controller.generate_static_pw', [keyboard_layout], cb)
    }

    function program_otp(slot, public_id, private_id, key, cb) {
        do_call('yubikey.controller.program_otp',
                [slot, public_id, private_id, key], cb)
    }

    function program_challenge_response(slot, key, touch, cb) {
        do_call('yubikey.controller.program_challenge_response',
                [slot, key, touch], cb)
    }

    function program_static_password(slot, password, keyboard_layout, cb) {
        do_call('yubikey.controller.program_static_password',
                [slot, password, keyboard_layout], cb)
    }

    function program_oath_hotp(slot, key, digits, cb) {
        do_call('yubikey.controller.program_oath_hotp', [slot, key, digits], cb)
    }

    function fido_support_ctap(cb) {
        do_call('yubikey.controller.fido_support_ctap', [], cb)
    }

    function fido_has_pin(cb) {
        do_call('yubikey.controller.fido_has_pin', [], cb)
    }

    function fido_set_pin(newPin, cb) {
        do_call('yubikey.controller.fido_set_pin', [newPin], cb)
    }

    function fido_change_pin(currentPin, newPin, cb) {
        do_call('yubikey.controller.fido_change_pin', [currentPin, newPin], cb)
    }

    function fido_reset(cb) {
        do_call('yubikey.controller.fido_reset', [], cb)
    }

    function fido_pin_retries(cb) {
        do_call('yubikey.controller.fido_pin_retries', [], cb)
    }
}
