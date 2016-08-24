import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

DefaultDialog {

    property int slot
    property var device

    title: qsTr("Configure YubiKey slot" + slot)

    ColumnLayout {

        Text {
            textFormat: Text.StyledText
            text: qsTr("<h2>Configure YubiKey slots</h2>")
        }

        GridLayout {
            columns: 2
            Button {
                text: "New configuration"
            }

            Button {
                text: "Erase"
                onClicked: eraseSlot()
            }
        }
    }

    function eraseSlot() {
        confirmErase.slot = slot
        confirmErase.open()
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
