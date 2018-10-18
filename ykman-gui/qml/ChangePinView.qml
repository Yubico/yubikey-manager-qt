import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property var breadcrumbs
    property string defaultCurrentPin
    property bool hasCurrentPin
    property int maxLength
    property int minLength

    property string codeName: qsTr("PIN")
    property string confirmNewPinLabel: qsTr("Confirm new %1:").arg(codeName)
    property string currentPinLabel: qsTr("Current %1:").arg(codeName)
    property string finishButtonText: qsTr("Change %1").arg(codeName)
    property string finishButtonTooltip: qsTr("Finish and change the %1")

    property string mainHeading: hasCurrentPin ? qsTr("Change %1").arg(
                                                     codeName) : qsTr(
                                                     "Set %1").arg(codeName)
    property string newPinLabel: qsTr("New %1:").arg(codeName)
    property string newPinTooltip: qsTr("The %1 must be at least %2 characters").arg(
                                       codeName).arg(minLength)

    readonly property alias chosenCurrentPin: currentPin.text
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    function validPin() {
        return (pinMatches) && (chosenPin.length >= minLength)
                && (chosenPin.length <= maxLength)
    }

    signal changePin(string currentPin, string newPin)
    signal clearCurrentPinInput
    signal clearNewPinInputs
    signal clearPinInputs

    function triggerChangePin() {
        changePin(chosenCurrentPin, chosenPin)
    }

    function toggleUseDefaultCurrentPin() {
        if (defaultCurrentPin) {
            if (useDefaultCurrentPinCheckbox.checked) {
                currentPin.text = defaultCurrentPin
            } else {
                currentPin.clear()
            }
        }
    }

    onClearNewPinInputs: {
        newPin.clear()
        confirmPin.clear()
    }

    onClearCurrentPinInput: {
        currentPin.clear()
        useDefaultCurrentPinCheckbox.checked = false
    }

    onClearPinInputs: {
        clearCurrentPinInput()
        clearNewPinInputs()
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
                text: currentPinLabel
                font.pixelSize: constants.h3
                color: yubicoBlue
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: hasCurrentPin
            }
            RowLayout {
                visible: hasCurrentPin

                TextField {
                    id: currentPin
                    Layout.fillWidth: true
                    echoMode: enabled ? TextInput.Password : TextInput.Normal
                    selectByMouse: true
                    selectionColor: yubicoGreen
                    enabled: !useDefaultCurrentPinCheckbox.checked
                }

                CheckBox {
                    id: useDefaultCurrentPinCheckbox
                    text: qsTr("Use default")
                    onCheckedChanged: toggleUseDefaultCurrentPin()
                    font.pixelSize: constants.h3
                    Material.foreground: yubicoBlue
                    visible: defaultCurrentPin
                }
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
            BackButton {
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
