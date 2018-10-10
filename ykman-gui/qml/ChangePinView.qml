import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property var breadcrumbs
    property bool hasCurrentPin
    property int maxLength
    property int minLength

    property string confirmNewPinLabel: qsTr("Confirm new PIN")
    property string finishButtonText: qsTr("Change PIN")
    property string finishButtonTooltip: qsTr("Finish and change the PIN")

    property string mainHeading: hasCurrentPin ? qsTr("Change PIN") : qsTr(
                                                     "Set PIN")
    property string newPinLabel: qsTr("New PIN")
    property string newPinTooltip: qsTr("The PIN must be at least %1 characters").arg(
                                       minLength)

    readonly property alias chosenCurrentPin: currentPin.text
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    function validPin() {
        return (pinMatches) && (chosenPin.length >= minLength)
                && (chosenPin.length <= maxLength)
    }

    signal changePin(string currentPin, string newPin)
    signal clearPinInputs
    signal goBack

    function triggerChangePin() {
        changePin(chosenCurrentPin, chosenPin)
    }

    onClearPinInputs: {
        currentPin.text = ''
        newPin.text = ''
        confirmPin.text = ''
    }

    CustomContentColumn {
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: mainHeading
            }

            BreadCrumbRow {
                items: breadcrumbs
            }
        }

        GridLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            columns: 2
            Layout.fillWidth: true

            Label {
                text: qsTr("Current PIN")
                font.pixelSize: constants.h3
                color: yubicoBlue
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: hasCurrentPin
            }
            TextField {
                id: currentPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectByMouse: true
                selectionColor: yubicoGreen
                visible: hasCurrentPin
            }

            Label {
                text: newPinLabel
                font.pixelSize: constants.h3
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            TextField {
                id: newPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: newPinTooltip
                selectByMouse: true
                selectionColor: yubicoGreen
            }

            Label {
                text: confirmNewPinLabel
                font.pixelSize: constants.h3
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            TextField {
                id: confirmPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectByMouse: true
                selectionColor: yubicoGreen
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            CustomButton {
                text: qsTr("Back")
                onClicked: goBack()
                iconSource: "../images/back.svg"
            }
            CustomButton {
                enabled: validPin()
                text: finishButtonText
                highlighted: true
                onClicked: triggerChangePin()
                toolTipText: finishButtonTooltip
                iconSource: "../images/finish.svg"
            }
        }
    }
}
