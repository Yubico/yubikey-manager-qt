import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

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
        if (valid(currentInput.text, newInput.text, repeatInput.text)) {
            codeChanged(currentInput.text, newInput.text)
        }
    }

    onActiveFocusChanged: {
        hasCode ? currentInput.forceActiveFocus() : newInput.forceActiveFocus()
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
            enabled: valid(currentInput.text, newInput.text, repeatInput.text)
        }
    }

    function validPinLength(pinLength) {
        return pinLength >= minLength && pinLength <= maxLength
    }

    function validPinRepetition(newPin, repeatPin) {
        return newPin === repeatPin
    }

    function valid(currentPin, newPin, repeatPin) {
        return (hasCode ? validPinLength(currentPin.length) : true)
                && validPinLength(newPin.length) && validPinRepetition(
                    newPin, repeatPin)
    }

    Shortcut {
        sequence: 'Return'
        onActivated: accepted()
        enabled: acceptBtn.enabled
    }
}
