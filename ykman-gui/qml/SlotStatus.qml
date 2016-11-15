import QtQuick 2.0
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

    Text {
        text: SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Text {
        text: qsTr("The slot is ") + SlotUtils.configuredTxt(slotsEnabled[selectedSlot - 1]) + "."
    }

    GridLayout {
        columns: 2
        Button {
            text: qsTr("New configuration")
            onClicked: goToSelectType()
        }

        Button {
            text: qsTr("Erase")
            enabled: slotsEnabled[selectedSlot - 1]
            onClicked: confirmErase.open()
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: goToOverview()
        }
    }

    MessageDialog {
        id: confirmErase
        icon: StandardIcon.Warning
        title: qsTr("Erase YubiKey ") + SlotUtils.slotName(selectedSlot) + qsTr("slot")
        text: qsTr("Do you want to erase the content of the ") + SlotUtils.slotName(
                  selectedSlot) + qsTr(" slot? This permanently deletes the contents of this slot.")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(selectedSlot, function (error) {
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
