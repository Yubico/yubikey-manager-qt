import QtQuick 2.9
import io.thp.pyotherside 1.4
import "utils.js" as Utils


// @disable-check M300
Python {

    property int nDevices
    property bool hasDevice
    property string name
    property string version
    property string serial
    property bool canWriteConfig
    property bool configurationLocked

    property var applicationsEnabledOverUsb: []
    property var applicationsEnabledOverNfc: []

    property var applicationsSupportedOverUsb: []
    property var applicationsSupportedOverNfc: []

    property var usbInterfacesSupported: []
    property var usbInterfacesEnabled: []

    property bool yubikeyModuleLoaded: false
    property bool yubikeyReady: false
    property var queue: []
    property var piv
    property bool pivPukBlocked: false

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

    function clearYubiKey() {
        hasDevice = false
        name = ''
        version = ''
        serial = ''
        configurationLocked = false
        usbInterfacesSupported = []
        usbInterfacesEnabled = []
        applicationsSupportedOverUsb = []
        applicationsEnabledOverUsb = []
        applicationsSupportedOverNfc = []
        applicationsEnabledOverNfc = []
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

    function isNEO() {
        return name === 'YubiKey NEO'
    }

    function isYubiKeyEdge() {
        return name === 'YubiKey Edge'
    }

    function isYubiKey4() {
        return name === 'YubiKey 4'
    }

    function isSecurityKeyByYubico() {
        return name === 'Security Key by Yubico'
    }

    function isFidoU2fSecurityKey() {
        return name === 'FIDO U2F Security Key'
    }

    function isYubiKeyStandard() {
        return name === 'YubiKey Standard'
    }

    function isYubiKeyPreview() {
        return name === 'YubiKey Preview'
    }

    function isYubiKey5NFC() {
        return name === 'YubiKey 5 NFC'
    }

    function isYubiKey5Nano() {
        return name === 'YubiKey 5 Nano'
    }

    function isYubiKey5C() {
        return name === 'YubiKey 5C'
    }

    function isYubiKey5CNano() {
        return name === 'YubiKey 5C Nano'
    }

    function isYubiKey5A() {
        return name === 'YubiKey 5A'
    }

    function isYubiKey5Family() {
        return name.startsWith('YubiKey 5')
    }

    function supportsNewInterfaces() {
        return isYubiKeyPreview() || isYubiKey5Family()
    }

    function supportsNfcConfiguration() {
        return applicationsSupportedOverNfc.length > 0
    }
    function supportsUsbConfiguration() {
        return applicationsSupportedOverUsb.length > 1
    }

    function canChangeInterfaces() {
        return usbInterfacesSupported.length > 1
    }

    function otpInterfaceSupported() {
        return Utils.includes(usbInterfacesSupported, 'OTP')
    }

    function fidoInterfaceSupported() {
        return Utils.includes(usbInterfacesSupported, 'FIDO')
    }

    function ccidInterfaceSupported() {
        return Utils.includes(usbInterfacesSupported, 'CCID')
    }

    function isEnabledOverUsb(applicationId) {
        return Utils.includes(applicationsEnabledOverUsb, applicationId)
    }

    function isEnabledOverNfc(applicationId) {
        return Utils.includes(applicationsEnabledOverNfc, applicationId)
    }

    function isSupportedOverUSB(applicationId) {
        return Utils.includes(applicationsSupportedOverUsb, applicationId)
    }

    function isSupportedOverNfc(applicationId) {
        return Utils.includes(applicationsSupportedOverNfc, applicationId)
    }

    function refresh(doneCallback) {
        do_call('yubikey.controller.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                do_call('yubikey.controller.refresh', [], function (resp) {
                    if (!resp.error && resp.dev) {
                        hasDevice = true
                        name = resp.dev.name
                        version = resp.dev.version
                        serial = resp.dev.serial
                        configurationLocked = resp.dev.configuration_locked
                        applicationsSupportedOverUsb = resp.dev.usb_supported
                        applicationsEnabledOverUsb = resp.dev.usb_enabled
                        applicationsSupportedOverNfc = resp.dev.nfc_supported
                        applicationsEnabledOverNfc = resp.dev.nfc_enabled
                        usbInterfacesSupported = resp.dev.usb_interfaces_supported
                        usbInterfacesEnabled = resp.dev.usb_interfaces_enabled
                        canWriteConfig = resp.dev.can_write_config
                    } else {
                        clearYubiKey()
                    }
                })
            } else if (hasDevice) {
                clearYubiKey()
            }

            if (doneCallback) {
                doneCallback()
            }
        })
    }

    function write_config(usbApplications, nfcApplications, lockCode, cb) {
        do_call('yubikey.controller.write_config',
                [usbApplications, nfcApplications, lockCode], cb)
    }

    function refreshPiv(doneCallback) {
        if (hasDevice) {
            do_call('yubikey.controller.refresh_piv', [], function (pivData) {
                piv = pivData
                doneCallback()
            })
        } else {
            doneCallback()
        }
    }

    /**
     * Transform a `callback` into one that will first call `refreshPiv` and then
     * itself when `refresh` is done.
     *
     * The arguments and `this` context of the call to the `callback` are
     * preseved.
     *
     * @param callback a function
     *
     * @return a function which will call `refreshPiv()` and delay the execution of
     *          the `callback` until the `refreshPiv()` is done.
     */
    function _refreshPivBefore(callback) {
        return function (/* ...arguments */ ) {
            var callbackThis = this
            var callbackArguments = arguments
            refreshPiv(function () {
                callback.apply(callbackThis, callbackArguments)
            })
        }
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

    function piv_change_pin(old_pin, new_pin, cb) {
        do_call('yubikey.controller.piv_change_pin', [old_pin, new_pin],
                _refreshPivBefore(cb))
    }

    function piv_change_puk(old_puk, new_puk, cb) {
        do_call('yubikey.controller.piv_change_puk', [old_puk, new_puk],
                _refreshPivBefore(function (resp) {
                    if (!resp.success && resp.tries_left < 1) {
                        pivPukBlocked = true
                    }
                    cb(resp)
                }))
    }

    function piv_reset(cb) {
        do_call('yubikey.controller.piv_reset', [],
                _refreshPivBefore(function (resp) {
                    pivPukBlocked = false
                    cb(resp)
                }))
    }

    function piv_unblock_pin(puk, newPin, cb) {
        do_call('yubikey.controller.piv_unblock_pin', [puk, newPin],
                _refreshPivBefore(cb))
    }
}
