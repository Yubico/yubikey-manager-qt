import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("Set PIN for FIDO 2")
    minimumWidth: 250
    maximumWidth: 250
    modality: Qt.ApplicationModal

    property bool validNewPin: newPin.text.length >= 4
                               && newPin.text == confirmPin.text
    property bool hasPin

    ColumnLayout {

        GridLayout {
            columns: 2
            Label {
                text: qsTr("Current PIN: ")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.fillWidth: false
                visible: hasPin
            }
            TextField {
                id: currentPin
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Keys.onEscapePressed: close()
                visible: hasPin
            }

            Label {
                text: qsTr("New PIN: ")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.fillWidth: false
            }
            TextField {
                id: newPin
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Keys.onEscapePressed: close()
            }
            Label {
                text: qsTr("Confirm PIN: ")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.fillWidth: false
            }
            TextField {
                id: confirmPin
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Keys.onEscapePressed: close()
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
                onClicked: close()
            }
            Button {
                text: qsTr("Set PIN")
                enabled: validNewPin
                onClicked: updatePin()
            }
        }
    }

    function load() {
        device.fido_has_pin(showDialog)
    }

    function showDialog(res) {
        hasPin = res
        show()
    }

    function updatePin() {
        var _currentPin = currentPin.text || null
        var _newPin = newPin.text
        if (hasPin) {
            device.fido_change_pin(_currentPin, _newPin, handleChangePin)
        } else {
            device.fido_set_pin(_newPin, handleChangePin)
        }
    }

    function handleChangePin(res) {
        if (!res) {
            close()
            fidoPinConfirmation.open()
        }
        close()
    }
}
