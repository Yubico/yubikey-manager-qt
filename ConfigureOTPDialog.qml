import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Dialog {
    property var device
    property bool hasDevice: device ? device.hasDevice : false

    onHasDeviceChanged: close()

    title: qsTr("Configure YubiKey slots")

    GridLayout{
        columns: 4

        Text {
            text: qsTr("Slot 1 (short press):")
        }

        Text {
            id: slot1Txt
        }

        Button {
            text: qsTr("Configure")
            onClicked: resize()
        }

        Button {
            text: qsTr("Erase")
        }

        Text {
            text: qsTr("Slot 2 (short press):")
        }

        Text {
            id: slot2Txt
        }

        Button {
            text: qsTr("Configure")
        }

        Button {
            text: qsTr("Erase")
        }
    }

    function init() {
        device.slots_status(function(res) {
            slot1Txt.text = statusText(res[0])
            slot2Txt.text = statusText(res[1])
            show()
        })
    }

    function statusText(programmed) {
        return programmed ? qsTr("Programmed") : qsTr("Empty")
    }
}


