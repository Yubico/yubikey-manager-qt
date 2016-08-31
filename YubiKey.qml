import QtQuick 2.0
import io.thp.pyotherside 1.4


// @disable-check M300
Python {
    id: py

    property int nDevices
    property bool hasDevice
    property string name
    property string version
    property string serial
    property var features: []
    property var connections: []
    property var enabled: []

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('.'))
        importModule('yubikey', function () {
            do_call('yubikey.controller.get_features', [], function (res) {
                features = res
            })
        })

    }

    onError: {
        console.log('Python error: ' + traceback)
    }

    function do_call(func, args, cb) {
        call(func, args, function(json) {
            cb(json ? JSON.parse(json) : undefined)
        })
    }


    function refresh() {
        do_call('yubikey.controller.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                do_call('yubikey.controller.refresh', [], function (dev) {
                    hasDevice = dev !== undefined
                    name = dev ? dev.name : ''
                    version = dev ? dev.version : ''
                    serial = dev ? dev.serial : ''
                    enabled = dev ? dev.enabled : []
                    connections = dev ? dev.connections : []
                })
            } else if (hasDevice) {
                hasDevice = false
            }
        })

    }

    function set_mode(connections, cb) {
        do_call('yubikey.controller.set_mode', [connections], cb)
    }

    function slots_status(cb) {
        do_call('yubikey.controller.slots_status', [], cb)
    }

    function erase_slot(slot) {
        do_call('yubikey.controller.erase_slot', [slot])
    }

    function swap_slots() {
        do_call('yubikey.controller.swap_slots', [])
    }

    function serial_modhex(cb) {
        do_call('yubikey.controller.serial_modhex', [], cb)
    }

    function random_uid(cb) {
        do_call('yubikey.controller.random_uid', [], cb)
    }

    function random_key(cb) {
        do_call('yubikey.controller.random_key', [], cb)
    }

    function program_otp(slot, public_id, private_id, key, cb) {
        do_call('yubikey.controller.program_otp', [slot, public_id, private_id, key], cb)
    }
}
