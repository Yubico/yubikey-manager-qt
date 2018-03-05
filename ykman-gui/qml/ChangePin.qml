import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ColumnLayout {

    property string codeName: 'PIN'
    property string currentCodeLabel: qsTr('Current %1:').arg(codeName)
    property int maxLength: 8
    property int minLength: 6

    property string normalColor: 'black'
    property string errorColor: 'red'

    signal accepted()
    signal canceled()
    signal codeChanged(string currentCode, string newCode)

    onAccepted: {
        if (valid(currentInput.text, newInput.text, repeatInput.text)) {
            codeChanged(currentInput.text, newInput.text)
            reset()
        } else {
            state.attemptMade = true
        }
    }

    Component.onCompleted: reset()

    function reset() {
        currentInput.focus = true
        currentInput.text = ''
        newInput.text = ''
        repeatInput.text = ''
        state.attemptMade = false
    }

    // Private state container
    QtObject {
        id: state
        property bool attemptMade: false
    }

    Label {
        //: Input field for the current value of the code (for example PIN) to be changed
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
        text: qsTr('New %1 (%2-%3 characters):').arg(codeName).arg(minLength).arg(maxLength)
        color: shouldShowPinLengthError(newInput.text) ? errorColor : normalColor
    }

    TextField {
        id: newInput
        echoMode: TextInput.Password
        maximumLength: maxLength
    }

    Label {
        //: Input field for the new value to change the code (for example PIN) to
        text: qsTr('Repeat %1:').arg(codeName)
        color: shouldShowPinRepetitionError(newInput.text, repeatInput.text) ? errorColor : normalColor
    }

    TextField {
        id: repeatInput
        echoMode: TextInput.Password
        maximumLength: maxLength
    }

    Label {
        id: overallError

        text: computeErrorMessage(currentInput.text, newInput.text, repeatInput.text)

        color: errorColor
        font.italic: true
    }

    RowLayout {
        Button {
            text: qsTr('Cancel')
            onClicked: canceled()
        }

        Button {
            text: qsTr('Ok')
            onClicked: accepted()
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

    function shouldShowPinLengthError(newPin) {
        return (validPinLength(newPin) === false) && (newPin.length > 0 || state.attemptMade)
    }

    function shouldShowPinRepetitionError(newPin, repeatPin) {
        return (validPinRepetition(newPin, repeatPin) === false) && (newPin.length > 0 && repeatPin.length > 0 || state.attemptMade)
    }

    function computeErrorMessage(currentPin, newPin, repeatPin) {
        if (shouldShowPinLengthError(newPin)) {
            return qsTr('New %1 must be %2-%3 characters.').arg(codeName).arg(minLength).arg(maxLength)
        } else if (shouldShowPinRepetitionError(newPin, repeatPin)) {
            return qsTr('Repeated %1 does not match.').arg(codeName)
        } else {
            return ''
        }
    }

    Shortcut {
        sequence: 'Return'
        onActivated: accepted()
    }

}
