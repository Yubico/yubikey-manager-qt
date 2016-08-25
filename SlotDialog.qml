import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("Configure YubiKey slots")

    property var device
    property bool hasDevice: device ? device.hasDevice : false
    property bool slot1enabled
    property bool slot2enabled

    onHasDeviceChanged: close()

    onSlot1enabledChanged: {
        updateSlotElements()
    }

    onSlot2enabledChanged: {
        updateSlotElements()
    }

    ColumnLayout {
        id: container

        Text {
            textFormat: Text.StyledText
            text: qsTr("<h2>Configure YubiKey slots</h2>")
        }

        GridLayout {
            columns: 3

            Text {
                text: qsTr("Short press:")
            }

            Text {
                id: slot1Txt
            }

            Button {
                text: qsTr("Configure")
                onClicked: openSlotWizard(1)
            }

            Text {
                text: qsTr("Long press:")
            }

            Text {
                id: slot2Txt
            }

            Button {
                text: qsTr("Configure")
                onClicked: openSlotWizard(2)
            }

            Button {
                text: qsTr("Swap credentials between slots")
                Layout.columnSpan : 2
                onClicked: {
                    console.log("Swapping...")
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
    }

    function updateSlotElements() {
        slot1Txt.text = statusText(slot1enabled)
        slot2Txt.text = statusText(slot2enabled)
    }

    function statusText(configured) {
        return configured ? qsTr("Configured") : qsTr("Empty")
    }

    function openSlotWizard(slot) {
        device.slots_status(function (res) {
            slotWizard.slot = slot
            var configured = res[slot - 1]
            if (configured) {
                slotWizard.device = device
                slotWizard.resetLoader()
                slotWizard.show()
            } else {
                console.log("Not configured, open configuration wizard.")
            }
        })
    }

    SlotWizard {
        id: slotWizard
    }
}
