import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

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

    Text {
        text: qsTr("Configure YubiKey Slots")
        font.bold: true
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3

        Text {
            id: shortPressLabel
            text: qsTr("Short press:")
        }

        Text {
            anchors {
                margins: 10
                left: shortPressLabel.right
            }
            text: slotsEnabled[0] ? qsTr("Configured") : qsTr("Empty")
        }

        Button {
            anchors {
                right: parent.right
            }
            text: qsTr("Configure")
            onClicked: configureSlot(1)
        }

        Text {
            id: longPressLabel
            text: qsTr("Long press:")
        }

        Text {
            anchors {
                margins: 10
                left: longPressLabel.right
            }
            text: slotsEnabled[1] ? qsTr("Configured") : qsTr("Empty")
        }

        Button {
            anchors {
                right: parent.right
            }
            text: qsTr("Configure")
            onClicked: configureSlot(2)
        }

        Button {
            text: qsTr("Swap credentials between slots")
            Layout.columnSpan: 2
            onClicked: confirmSwap.open()
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight

        Button {
            text: qsTr("Close")
            onClicked: close()
        }
    }

    MessageDialog {
        id: confirmSwap
        icon: StandardIcon.Warning
        title: "Swap credentials between slots"
        text: "Do you want to swap the credentials between the short press and the long press slot?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.swap_slots(function (error) {
                if (!error) {
                    close()
                    updateStatus()
                    confirmSwapped.open()
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
        id: confirmSwapped
        icon: StandardIcon.Information
        title: "Slot credentials swapped"
        text: "The credentials in the short press and the long press slot has now been swapped."
        standardButtons: StandardButton.Ok
        onAccepted: {
            goToOverview()
        }
    }
}
