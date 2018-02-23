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
    property var connections: []
    property var capabilities: []
    property var enabled: []
    property bool yubikeyModuleLoaded: false
    property bool yubikeyReady: false
    property var queue: []
    property var piv: {}

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
                    capabilities = dev ? dev.capabilities : []
                    enabled = dev ? dev.enabled : []
                    connections = dev ? dev.connections : []
                    piv = dev && dev.piv
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

    function generate_static_pw(cb) {
        do_call('yubikey.controller.generate_static_pw', [], cb)
    }

    function program_otp(slot, public_id, private_id, key, cb) {
        do_call('yubikey.controller.program_otp',
                [slot, public_id, private_id, key], cb)
    }

    function program_challenge_response(slot, key, touch, cb) {
        do_call('yubikey.controller.program_challenge_response',
                [slot, key, touch], cb)
    }

    function program_static_password(slot, password, cb) {
        do_call('yubikey.controller.program_static_password',
                [slot, password], cb)
    }

    function program_oath_hotp(slot, key, digits, cb) {
        do_call('yubikey.controller.program_oath_hotp', [slot, key, digits], cb)
    }

    function openpgp_reset(cb) {
        do_call('yubikey.controller.openpgp_reset', [], cb)
    }

    function openpgp_get_touch(cb) {
        do_call('yubikey.controller.openpgp_get_touch', [], cb)
    }

    function openpgp_set_touch(adminPin, authKeyPolicy, encKeyPolicy, sigKeyPolicy, cb) {
        do_call('yubikey.controller.openpgp_set_touch',
                [adminPin, authKeyPolicy, encKeyPolicy, sigKeyPolicy], cb)
    }

    function openpgp_set_pin_retries(adminPin, pinRetries, resetCodeRetries, adminPinRetries, cb) {
        do_call('yubikey.controller.openpgp_set_pin_retries',
                [adminPin, pinRetries, resetCodeRetries, adminPinRetries], cb)
    }

    function openpgp_get_remaining_pin_retries(cb) {
        do_call('yubikey.controller.openpgp_get_remaining_pin_retries', [], cb)
    }

    function openpgp_get_version(cb) {
        do_call('yubikey.controller.openpgp_get_version', [], cb)
    }

    function piv_change_pin(old_pin, new_pin, cb) {
        do_call('yubikey.controller.piv_change_pin', [old_pin, new_pin], cb)
    }

    function piv_change_puk(old_puk, new_puk, cb) {
        do_call('yubikey.controller.piv_change_puk', [old_puk, new_puk], cb)
    }

    function piv_generate_random_mgm_key(cb) {
        do_call('yubikey.controller.piv_generate_random_mgm_key', [], cb)
    }

    function piv_change_mgm_key(cb, pin, currentMgmKey, newKey, touch, touchCallback, storeOnDevice) {
        var touchPromptTimer = Utils.delay(touchCallback, 500)

        // PyOtherSide doesn't seem to support passing through functions as arguments
        do_call('yubikey.controller.piv_change_mgm_key',
                [pin, currentMgmKey, newKey, touch, storeOnDevice],
                function (result) {
                    touchPromptTimer.stop()
                    refresh(function() {
                        cb(result)
                    })
                })
    }

    function piv_reset(cb) {
        do_call('yubikey.controller.piv_reset', [], function(result) {
            refresh(function() {
                cb(result)
            })
        })
    }

}
