import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Dialog {

    property string codeName: 'PIN'
    property int maxLength: 8
    property int minLength: 6

    property string normalColor: 'black'
    property string errorColor: 'red'

    signal canceled()
    signal codeChanged(string currentCode, string newCode)

    onAccepted: {
        if (valid(currentInput.text, newInput.text, repeatInput.text)) {
            codeChanged(currentInput.text, newInput.text)
            reset()
        } else {
            state.attemptMade = true
            retryTimer.start()
        }
    }

    onRejected: {
        reset()
        canceled()
    }

    onVisibleChanged: {
        if (visible) {
            currentInput.focus = true
        }
    }

    standardButtons: StandardButton.Cancel | StandardButton.Ok
    //: User input window title
    title: qsTr('Change %1').arg(codeName)

    function reset() {
        currentInput.text = ''
        newInput.text = ''
        repeatInput.text = ''
        state.attemptMade = false
    }

    Timer {
        // Ugly workaround to a likely bug in Qt: open() in onAccepted fails if
        // the user clicks the Ok button, but works if the user presses Return.
        // Using a 0 ms timer ensures the open() call is deferred to after the
        // window is properly destroyed.
        id: retryTimer
        interval: 0
        repeat: false
        onTriggered: open()
    }

    // Private state container
    QtObject {
        id: state
        property bool attemptMade: false
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            //: Input field for the current value of the code (for example PIN) to be changed
            text: qsTr('Current %1:').arg(codeName)
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

}
