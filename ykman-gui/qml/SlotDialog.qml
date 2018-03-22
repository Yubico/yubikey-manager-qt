import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

DefaultDialog {
    title: qsTr("Configure YubiKey Slots")
    minimumHeight: calcHeight()
    height: minimumHeight
    minimumWidth: calcWidth()
    width: minimumWidth
    property var device
    property var slotsConfigured: [false, false]
    property int selectedSlot

    function calcWidth() {
        return stack.currentItem ? Math.max(
                                       350,
                                       stack.currentItem.implicitWidth + (margins * 2)) : 0
    }

    function calcHeight() {
        return stack.currentItem ? stack.currentItem.implicitHeight + (margins * 2) : 0
    }

    function load() {
        selectedSlot = 0
        stack.push({
                       item: slotOverview,
                       immediate: true,
                       replace: true
                   })
        device.slots_status(function (res) {
            slotsConfigured = res
            show()
        })
    }

    function deleteSlot() {
        device.erase_slot(selectedSlot, function (error) {
            if (!error) {
                confirmErased.open()
            } else {
                if (error === 3) {
                    writeError.open()
                }
            }
        })
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: slotOverview
        onCurrentItemChanged: {
            if (currentItem) {
                currentItem.forceActiveFocus()
            }
        }
    }

    Component {
        id: slotOverview
        SlotOverview {
        }
    }

    Component {
        id: slotSelectType
        SlotSelectType {
        }
    }

    Component {
        id: slotConfigureOTP
        SlotConfigureOTP {
        }
    }

    Component {
        id: slotConfigureChallengeResponse
        SlotConfigureChallengeResponse {
        }
    }

    Component {
        id: slotConfigureStaticPassword
        SlotConfigureStaticPassword {
        }
    }

    Component {
        id: slotConfigureOathHotp
        SlotConfigureOathHotp {
        }
    }

    SwapSlotDialog {
        id: swapSlotsDialog
    }

    MessageDialog {
        id: confirmSwapped
        icon: StandardIcon.Information
        title: qsTr("Slot credentials swapped")
        text: qsTr("The credentials in the short press and the long press slot have now been swapped.")
        standardButtons: StandardButton.Ok
        onAccepted: slotDialog.load()
    }

    MessageDialog {
        id: deleteSlotDialog
        icon: StandardIcon.Warning
        title: qsTr("Erase YubiKey ") + SlotUtils.slotName(
                   selectedSlot) + qsTr("slot")
        text: qsTr("Do you want to erase the content of the ") + SlotUtils.slotName(
                  selectedSlot) + qsTr(
                  " slot? This permanently deletes the configuration of this slot.")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: deleteSlot()
        onNo: close()
    }

    MessageDialog {
        id: confirmErased
        icon: StandardIcon.Information
        title: qsTr("The credentials have been erased")
        text: qsTr("The credentials in the slot have now been erased.")
        standardButtons: StandardButton.Ok
        onAccepted: slotDialog.load()
    }

    MessageDialog {
        id: confirmConfigured
        icon: StandardIcon.Information
        title: qsTr("Slot configured")
        text: SlotUtils.slotNameCapitalized(selectedSlot) + qsTr(
                  " is now configured.")
        standardButtons: StandardButton.Ok
        onAccepted: slotDialog.load()
    }

    MessageDialog {
        id: writeError
        icon: StandardIcon.Critical
        title: qsTr("Error writing to slot")
        text: qsTr("Failed to write to the slot. Make sure the YubiKey does not have restricted access.")
        standardButtons: StandardButton.Ok
    }
}
