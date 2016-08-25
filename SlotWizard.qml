import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

DefaultDialog {

    property int slot
    property var device
    property bool configured

    signal resetIndex
    onResetIndex: stack.currentIndex = 0

    title: qsTr("Configure YubiKey slots")

    StackLayout {
        id: stack

        ColumnLayout {

            Text {
                textFormat: Text.StyledText
                text: "<h2>" + getHeading(slot) + "</h2>
<p>The slot is configured.</p>"
            }

            GridLayout {
                columns: 2
                Button {
                    text: "New configuration"
                    onClicked: chooseType()
                }

                Button {
                    id: eraseButton
                    Layout.fillWidth: true
                    text: "Erase"
                    onClicked: eraseSlot()
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

        ColumnLayout {
            Text {
                textFormat: Text.StyledText
                text: "Choose type of slot"
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    id: btn_cancel
                    text: qsTr("Close")
                    onClicked: close()
                }
            }
        }
    }

    function chooseType() {
        stack.currentIndex = 1
    }

    function eraseSlot() {
        confirmErase.slot = slot
        confirmErase.open()
    }

    function getHeading(slot) {
        if (slot === 1)
            return "Short press"
        if (slot === 2)
            return "Long press"
    }

    MessageDialog {
        property int slot
        id: confirmErase
        icon: StandardIcon.Warning
        title: "Erase YubiKey slot" + slot
        text: "Do you want to erase the content of slot " + slot
              + "? This permanently deletes the contents of this slot."
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(slot)
            close()
        }
        onNo: close()
    }
}
