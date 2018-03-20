import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

DefaultDialog {

    title: qsTr("Configure YubiKey Slots")
    property var device

    property var slotsConfigured: [false, false]
    property int selectedSlot
    minimumWidth: 350
    width: 350
    minimumHeight: calculated()
    height: calculated()

    function load() {
        selectedSlot = 0
        stack.push({
                       item: initial,
                       immediate: true,
                       replace: true
                   })
        device.slots_status(function (res) {
            slotsConfigured = res
            show()
        })
    }

    function calculated() {
        var stackItem = stack.currentItem
        var doubleMargins = margins * 2
        return stackItem ? stackItem.implicitHeight + doubleMargins : 0
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
        initialItem: initial
    }

    Component {
        id: initial
        ColumnLayout {
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Short Press (Slot 1)")
                ColumnLayout {
                    anchors.fill: parent
                    Label {
                        text: qsTr("The Short Press slot is currently ")
                              + (slotsConfigured[0] ? qsTr(
                                                          "configured.") : qsTr(
                                                          "empty."))
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Button {
                            text: qsTr("Delete...")
                            enabled: slotsConfigured[0]
                            onClicked: {
                                selectedSlot = 1
                                deleteSlotDialog.open()
                            }
                        }
                        Button {
                            text: qsTr("Configure...")
                            onClicked: {
                                selectedSlot = 1
                                stack.push({
                                               item: slotSelectType,
                                               immediate: true
                                           })
                            }
                        }
                    }
                }
            }
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Long Press (Slot 2)")
                ColumnLayout {
                    anchors.fill: parent
                    Label {
                        text: qsTr("The Long Press slot is currently ")
                              + (slotsConfigured[1] ? qsTr(
                                                          "configured.") : qsTr(
                                                          "empty."))
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Button {
                            enabled: slotsConfigured[1]
                            text: qsTr("Delete...")
                            onClicked: {
                                selectedSlot = 2
                                deleteSlotDialog.open()
                            }
                        }
                        Button {
                            text: qsTr("Configure...")
                            onClicked: {
                                selectedSlot = 2
                                stack.push({
                                               item: slotSelectType,
                                               immediate: true
                                           })
                            }
                        }
                    }
                }
            }
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Swap slots")
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: qsTr("Swap configuration between slots.")
                    }
                    Button {
                        text: qsTr("Swap...")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        enabled: slotsConfigured[0] || slotsConfigured[1]
                        onClicked: swapSlotsDialog.open()
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Button {
                    text: qsTr("Cancel")
                    onClicked: close()
                }
            }
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
        text: qsTr("The credentials in the short press and the long press slot has now been swapped.")
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
