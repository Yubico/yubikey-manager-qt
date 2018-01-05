import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

    property var device
    property var slotsEnabled: [false, false]
    property int selectedSlot
    signal configureSlot(int slot)
    signal updateStatus
    signal goToOverview
    signal goToSelectType
    signal goToSlotStatus
    signal goToConfigureOTP
    signal goToChallengeResponse
    signal goToStaticPassword
    signal goToOathHotp

    onDeviceChanged: update()

    Label {
        text: qsTr("Configure YubiKey Slots")
        font.bold: true
    }


    GridLayout {
        Layout.fillWidth: true
        columns: 2

        RadioButton {
            id: shortPress
            exclusiveGroup: slotRadioBtns
            checked: selectedSlot == 1
            text: qsTr("Short Press (Slot 1):")
            property int slotNumber: 1
        }

        Label {
            anchors {
                margins: 10
                left: shortPress.right
            }
            text: slotsEnabled[0] ? qsTr("Configured") : qsTr("Empty")
        }

        RadioButton {
            id: longPress
            exclusiveGroup: slotRadioBtns
            checked: selectedSlot == 2
            text: qsTr("Long Press (Slot 2):")
            property int slotNumber: 2
        }

        Label {
            anchors {
                margins: 10
                left: longPress.right
            }
            text: slotsEnabled[1] ? qsTr("Configured") : qsTr("Empty")
        }
    }

    ExclusiveGroup {
        id: slotRadioBtns
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight

        Button {
            text: qsTr("Cancel")
            onClicked: close()
        }
        Button {
            text: qsTr("Delete configuration")
            enabled: slotRadioBtns.current !== null
                     && slotsEnabled[slotRadioBtns.current.slotNumber - 1]
            onClicked: {
                confirmErase.slotNumber = slotRadioBtns.current.slotNumber
                confirmErase.open()
            }
        }
        Button {
            text: qsTr("New configuration")
            enabled: slotRadioBtns.current !== null
            onClicked: configureSlot(slotRadioBtns.current.slotNumber)
        }
    }

    MessageDialog {

        property int slotNumber

        id: confirmErase
        icon: StandardIcon.Warning
        title: qsTr("Erase YubiKey ") + SlotUtils.slotName(
                   slotNumber) + qsTr("slot")
        text: qsTr("Do you want to erase the content of the ") + SlotUtils.slotName(
                  slotNumber) + qsTr(
                  " slot? This permanently deletes the contents of this slot.")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(slotNumber, function (error) {
                if (!error) {
                    close()
                    updateStatus()
                    confirmErased.open()
                } else {
                    if (error === 3) {
                        writeError.open()
                    }
                }
            })
        }
        onNo: close()
    }

    MessageDialog {
        id: confirmErased
        icon: StandardIcon.Information
        title: qsTr("The credentials have been erased")
        text: qsTr("The credentials in the slot have now been erased.")
        standardButtons: StandardButton.Ok
    }
}
