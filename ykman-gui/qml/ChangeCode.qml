import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {

    property string codeName: qsTr('PIN')
    //: Input field for the current value of the code (for example PIN) to be changed
    property string currentCodeLabel: qsTr('Current %1:').arg(codeName)
    property string acceptBtnName: qsTr('Ok')
    property bool showRequirements: true
    property int maxLength: 8
    property int minLength: 6
    property bool hasCode: true
    property string headerText: ''

    signal accepted
    signal canceled
    signal codeChanged(string currentCode, string newCode)

    onAccepted: {
        if (valid(newInput.text, repeatInput.text)) {
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
        visible: headerText !== ''
        text: headerText
        font.bold: true
    }

    GridLayout {
        columns: 2
        Label {
            visible: hasCode
            text: currentCodeLabel
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillWidth: false
        }

        TextField {
            id: currentInput
            Layout.fillWidth: true
            visible: hasCode
            echoMode: TextInput.Password
            maximumLength: maxLength
            focus: true
        }

        Label {
            //: Input field for the new value to change the code (for example PIN) to
            text: showRequirements ? qsTr('New %1 (%2-%3 characters):').arg(
                                         codeName).arg(minLength).arg(
                                         maxLength) : qsTr(
                                         'New %1:').arg(codeName)
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillWidth: false
        }

        TextField {
            id: newInput
            Layout.fillWidth: true
            echoMode: TextInput.Password
            maximumLength: maxLength
        }

        Label {
            //: Input field for the new value to change the code (for example PIN) to
            text: qsTr('Confirm %1:').arg(codeName)
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillWidth: false
        }

        TextField {
            id: repeatInput
            Layout.fillWidth: true
            echoMode: TextInput.Password
            maximumLength: maxLength
            KeyNavigation.tab: cancelBtn
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            id: cancelBtn
            text: qsTr('Cancel')
            KeyNavigation.tab: acceptBtn
            onClicked: canceled()
        }

        Button {
            id: acceptBtn
            KeyNavigation.tab: hasCode ? currentInput : newInput
            text: acceptBtnName
            onClicked: accepted()
            enabled: valid(newInput.text, repeatInput.text)
        }
    }

    function validPinLength(newPin) {
        return newPin.length >= minLength && newPin.length <= maxLength
    }

    function validPinRepetition(newPin, repeatPin) {
        return newPin === repeatPin
    }

    function valid(newPin, repeatPin) {
        return validPinLength(newPin) && validPinRepetition(newPin, repeatPin)
    }

    Shortcut {
        sequence: 'Return'
        onActivated: accepted()
        enabled: acceptBtn.enabled
    }
}
