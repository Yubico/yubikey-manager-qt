import QtQuick 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Dialog {
    property var device
    property bool hasDevice: device ? device.hasDevice : false

    onHasDeviceChanged: close()

    title: qsTr("Configure YubiKey slots")

    GridLayout {
        columns: 4

        Text {
            text: qsTr("Slot 1 (short press):")
        }

        Text {
            id: slot1Txt
        }

        Button {
            text: qsTr("Configure")
        }

        Button {
            id: slot1EraseBtn
            text: qsTr("Erase")
            onClicked: eraseSlot(1)
        }

        Text {
            text: qsTr("Slot 2 (long press):")
        }

        Text {
            id: slot2Txt
        }

        Button {
            text: qsTr("Configure")
        }

        Button {
            id: slot2EraseBtn
            text: qsTr("Erase")
            onClicked: eraseSlot(2)
        }
    }

    function init() {
        device.slots_status(function (res) {
            slot1Txt.text = statusText(res[0])
            slot1EraseBtn.enabled = res[0]

            slot2Txt.text = statusText(res[1])
            slot2EraseBtn.enabled = res[1]

            show()
        })
    }

    function statusText(programmed) {
        return programmed ? qsTr("Programmed") : qsTr("Empty")
    }

    function eraseSlot(slot) {
        confirmErase.slot = slot
        confirmErase.open()
    }

    MessageDialog {
        property int slot
        id: confirmErase
        icon: StandardIcon.Warning
        title: "Erase YubiKey slot" + slot
        text: "Do you want to erase the content of slot " + slot + "? This permanently deletes the contents of this slot."
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(slot)
            close()
        }
        onNo: close()
    }
}
