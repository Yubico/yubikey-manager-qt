import QtQuick 2.0
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

    onDeviceChanged: update()

    Text {
        textFormat: Text.StyledText
        text: qsTr("<h2>Configure YubiKey slots</h2>")
    }
    GroupBox {
        GridLayout {
            columns: 3
            Text {
                text: qsTr("Short press:")
            }

            Text {
                text: slotsEnabled[0] ? qsTr("Configured") : qsTr("Empty")
            }

            Button {
                text: qsTr("Configure")
                onClicked: configureSlot(1)
            }

            Text {
                text: qsTr("Long press:")
            }

            Text {
                text: slotsEnabled[1] ? qsTr("Configured") : qsTr("Empty")
            }

            Button {
                text: qsTr("Configure")
                onClicked: configureSlot(2)
            }
            Button {
                text: qsTr("Swap credentials between slots")
                Layout.columnSpan: 2
                onClicked: confirmSwap.open()
            }
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
        text: "Do you want to swap the credentials between short press and long press?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.swap_slots()
            updateStatus()
            close()
        }
        onNo: close()
    }
}

