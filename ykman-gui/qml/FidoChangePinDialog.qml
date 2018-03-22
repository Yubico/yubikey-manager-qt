import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ColumnLayout {

    property bool validNewPin: newPin.text.length >= 4
                               && newPin.text == confirmPin.text

    Keys.onEscapePressed: close()

    Label {
        text: hasPin ? qsTr("Change FIDO 2 PIN") : qsTr("Set a FIDO 2 PIN")
        font.bold: true
    }

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
            KeyNavigation.tab: cancelBtn
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            id: cancelBtn
            text: qsTr("Cancel")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            id: setPinBtn
            KeyNavigation.tab: hasPin ? currentPin : newPin
            text: qsTr("Set PIN")
            enabled: validNewPin
            onClicked: updatePin()
        }
    }

    MessageDialog {
        id: fidoSetPinError
        icon: StandardIcon.Critical
        title: qsTr("Failed to set PIN.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
    }

    MessageDialog {
        id: fidoPinConfirmation
        icon: StandardIcon.Information
        title: qsTr("A new PIN has been set!")
        text: qsTr("Setting a PIN for the FIDO 2 Module was successful.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
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

    function handleChangePin(err) {
        if (!err) {
            fidoPinConfirmation.open()
        } else {
            fidoSetPinError.text = err
            fidoSetPinError.open()
        }
    }
}
