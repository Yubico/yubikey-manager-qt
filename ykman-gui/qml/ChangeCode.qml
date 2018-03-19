import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {

    property string codeName: qsTr('PIN')
    //: Input field for the current value of the code (for example PIN) to be changed
    property string currentCodeLabel: qsTr('Current %1:').arg(codeName)
    property int maxLength: 8
    property int minLength: 6

    signal accepted
    signal canceled
    signal codeChanged(string currentCode, string newCode)

    onAccepted: {
        if (valid(currentInput.text, newInput.text, repeatInput.text)) {
            codeChanged(currentInput.text, newInput.text)
            reset()
        }
    }
    onCanceled: reset()

    Component.onCompleted: reset()

    function reset() {
        currentInput.focus = true
        currentInput.text = ''
        newInput.text = ''
        repeatInput.text = ''
    }

    Label {
        text: currentCodeLabel
    }

    TextField {
        id: currentInput
        echoMode: TextInput.Password
        maximumLength: maxLength
        focus: true
    }

    Label {
        //: Input field for the new value to change the code (for example PIN) to
        text: qsTr('New %1 (%2-%3 characters):').arg(codeName).arg(
                  minLength).arg(maxLength)
    }

    TextField {
        id: newInput
        echoMode: TextInput.Password
        maximumLength: maxLength
    }

    Label {
        //: Input field for the new value to change the code (for example PIN) to
        text: qsTr('Repeat %1:').arg(codeName)
    }

    TextField {
        id: repeatInput
        echoMode: TextInput.Password
        maximumLength: maxLength
    }

    RowLayout {
        Button {
            text: qsTr('Cancel')
            onClicked: canceled()
        }

        Button {
            id: submitButton
            text: qsTr('Ok')
            onClicked: accepted()
            enabled: valid(currentInput.text, newInput.text, repeatInput.text)
        }
    }

    function validPinLength(newPin) {
        return newPin.length >= minLength && newPin.length <= maxLength
    }

    function validPinRepetition(newPin, repeatPin) {
        return newPin === repeatPin
    }

    function valid(currentPin, newPin, repeatPin) {
        return validPinLength(newPin) && validPinRepetition(newPin, repeatPin)
    }

    Shortcut {
        sequence: 'Return'
        onActivated: accepted()
        enabled: submitButton.enabled
    }
}
