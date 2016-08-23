import QtQuick 2.5
import io.thp.pyotherside 1.5


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
            call('yubikey.get_features', [], function (res) {
                features = res
            })
        })

    }

    onError: {
        console.log('Python error: ' + traceback)
    }


    function refresh() {
        call('yubikey.count_devices', [], function (n) {
            nDevices = n
            if (nDevices == 1) {
                call('yubikey.refresh', [], function (dev) {
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
        call('yubikey.set_mode', [connections], cb)
    }

    function slots_status(cb) {
        call('yubikey.slots_status', [], function (res) {
            cb(res)
        })
    }

    function erase_slot(slot) {
        call('yubikey.erase_slot', [slot])
    }
}
