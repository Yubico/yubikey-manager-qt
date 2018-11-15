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
        doCall('yubikey.init_with_logging',
               [logLevel || 'DEBUG', logFile || null], function () {
                   yubikeyReady = true
               })
    }
    onDisableLogging: {
        doCall('yubikey.init', [], function () {
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
            doCall(oldQueue[i][0], oldQueue[i][1], oldQueue[i][2])
        }
    }

    function doCall(func, args, cb) {
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
                || isSecurityKeyByYubico()
    }

    function supportsNfcConfiguration() {
        return applicationsSupportedOverNfc.length > 0
    }
    function supportsUsbConfiguration() {
        return applicationsSupportedOverUsb.length > 1
    }

    function canChangeInterfaces() {
        return usbInterfacesSupported.length > 1 || supportsUsbConfiguration()
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
        doCall('yubikey.controller.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                doCall('yubikey.controller.refresh', [], function (resp) {
                    if (resp.success && resp.dev) {
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

    function writeConfig(usbApplications, nfcApplications, lockCode, cb) {
        doCall('yubikey.controller.write_config',
               [usbApplications, nfcApplications, lockCode], cb)
    }

    function setMode(connections, cb) {
        doCall('yubikey.controller.set_mode', [connections], cb)
    }

    function slotsStatus(cb) {
        doCall('yubikey.controller.slots_status', [], cb)
    }

    function eraseSlot(slot, cb) {
        doCall('yubikey.controller.erase_slot', [slot], cb)
    }

    function swapSlots(cb) {
        doCall('yubikey.controller.swap_slots', [], cb)
    }

    function serialModhex(cb) {
        doCall('yubikey.controller.serial_modhex', [], cb)
    }

    function randomUid(cb) {
        doCall('yubikey.controller.random_uid', [], cb)
    }

    function randomKey(bytes, cb) {
        doCall('yubikey.controller.random_key', [bytes], cb)
    }

    function generateStaticPw(keyboardLayout, cb) {
        doCall('yubikey.controller.generate_static_pw', [keyboardLayout], cb)
    }

    function programOtp(slot, publicId, privateId, key, cb) {
        doCall('yubikey.controller.program_otp',
               [slot, publicId, privateId, key], cb)
    }

    function programChallengeResponse(slot, key, touch, cb) {
        doCall('yubikey.controller.program_challenge_response',
               [slot, key, touch], cb)
    }

    function programStaticPassword(slot, password, keyboardLayout, cb) {
        doCall('yubikey.controller.program_static_password',
               [slot, password, keyboardLayout], cb)
    }

    function programOathHotp(slot, key, digits, cb) {
        doCall('yubikey.controller.program_oath_hotp', [slot, key, digits], cb)
    }

    function fidoHasPin(cb) {
        doCall('yubikey.controller.fido_has_pin', [], cb)
    }

    function fidoSetPin(newPin, cb) {
        doCall('yubikey.controller.fido_set_pin', [newPin], cb)
    }

    function fidoChangePin(currentPin, newPin, cb) {
        doCall('yubikey.controller.fido_change_pin', [currentPin, newPin], cb)
    }

    function fidoReset(cb) {
        doCall('yubikey.controller.fido_reset', [], cb)
    }

    function fidoPinRetries(cb) {
        doCall('yubikey.controller.fido_pin_retries', [], cb)
    }
}
