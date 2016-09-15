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

    Text {
        textFormat: Text.StyledText
        text: "<h2>" + SlotUtils.slotNameCapitalized(selectedSlot) + "</h2> <p>The slot is " + SlotUtils.configuredTxt(slotsEnabled[selectedSlot - 1]) + ".</p>"
    }

    GridLayout {
        columns: 2
        Button {
            text: "New configuration"
            onClicked: goToSelectType()
        }

        Button {
            text: "Erase"
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
        title: "Erase YubiKey " + SlotUtils.slotName(selectedSlot) + "slot"
        text: "Do you want to erase the content of " + SlotUtils.slotName(selectedSlot)
              + " slot? This permanently deletes the contents of this slot."
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(selectedSlot)
            close()
            updateStatus()
        }
        onNo: close()
    }
}
