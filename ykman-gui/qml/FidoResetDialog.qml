import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("Reset FIDO 2")
    minimumWidth: 500
    maximumWidth: 500
    modality: Qt.ApplicationModal

    ColumnLayout {
        Label {
            text: "Reset FIDO 2 credentials"
            font.bold: true
        }
        Label {
            text: qsTr("A reset deletes all FIDO credentials on the device, and removes the PIN. The reset must triggered within 10 seconds after the YubiKey is inserted in the USB port, and requires a touch on the YubiKey.")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
                onClicked: close()
            }
            Button {
                text: qsTr("Reset")
                onClicked: reset()
            }
        }
    }

    function reset() {
        device.fido_reset(function (err) {})
    }
}
