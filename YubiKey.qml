import QtQuick 2.5
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
            do_call('yubikey.get_features', [], function (res) {
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
        do_call('yubikey.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                do_call('yubikey.refresh', [], function (dev) {
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
        do_call('yubikey.set_mode', [connections], cb)
    }

    function slots_status(cb) {
        do_call('yubikey.slots_status', [], cb)
    }

    function erase_slot(slot) {
        do_call('yubikey.erase_slot', [slot])
    }
}
