import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property var breadcrumbs
    property string defaultCurrentPin
    property bool hasCurrentPin
    property int maxLength: 32767 // Default max value for TextField.maximumWidth
    property int minLength

    property string codeName: qsTr("PIN")
    property string confirmNewPinLabel: qsTr("Confirm new %1").arg(codeName)
    property string currentPinLabel: qsTr("Current %1").arg(codeName)
    property string finishButtonText: qsTr("Change %1").arg(codeName)
    property string finishButtonTooltip: qsTr("Finish and change the %1").arg(
                                             codeName)

    property string mainHeading: hasCurrentPin ? qsTr("Change %1").arg(
                                                     codeName) : qsTr(
                                                     "Set %1").arg(codeName)
    property string newPinLabel: qsTr("New %1").arg(codeName)
    property string newPinTooltip: qsTr("The %1 must be at least %2 characters").arg(
                                       codeName).arg(minLength)

    readonly property alias chosenCurrentPin: currentPin.text
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    // To resolve name clash in ViewHeader
    readonly property var _breadcrumbs: breadcrumbs

    function validPin() {
        return (!hasCurrentPin || currentPin.length >= minLength)
                && (pinMatches) && (chosenPin.length >= minLength)
                && (chosenPin.length <= maxLength || !maxLength)
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
        ViewHeader {
            heading: mainHeading
            breadcrumbs: _breadcrumbs
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

                CustomTextField {
                    id: currentPin
                    Layout.fillWidth: true
                    echoMode: enabled ? TextInput.Password : TextInput.Normal
                    enabled: !useDefaultCurrentPinCheckbox.checked
                    maximumLength: maxLength
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
            CustomTextField {
                id: newPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                toolTipText: newPinTooltip
                maximumLength: maxLength
            }

            Label {
                text: confirmNewPinLabel
                font.pixelSize: constants.h3
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            CustomTextField {
                id: confirmPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                maximumLength: maxLength
            }
        }

        ButtonsBar {
            finishCallback: triggerChangePin
            finishEnabled: validPin()
            finishText: finishButtonText
            finishTooltip: finishButtonTooltip
        }
    }
}
