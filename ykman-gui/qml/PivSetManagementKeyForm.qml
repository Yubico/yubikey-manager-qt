import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

ColumnLayout {

    property var device
    property bool hasDevice: (device && device.hasDevice && device.piv) || false

    ColumnLayout {

        ExclusiveGroup { id: managementKeyTypeChoiceGroup }
        RadioButton {
            id: pinAsManagementKeyChoice
            text: qsTr("Use PIN as management key")
            exclusiveGroup: managementKeyTypeChoiceGroup
            checked: true
        }
        RadioButton {
            id: separateManagementKeyChoice
            text: qsTr("Use a separate management key")
            exclusiveGroup: managementKeyTypeChoiceGroup
        }

        ColumnLayout {
            visible: separateManagementKeyChoice.checked

            Label {
                text: qsTr("New management key:")
            }

            TextField {
                id: newManagementKeyInput
                maximumLength: 48
                focus: true
                Layout.fillWidth: true

                validator: RegExpValidator {
                    regExp: /[0-9a-f]{48}/
                }
            }

            Button {
                text: qsTr("Randomize")
                onClicked: newManagementKeyInput.text = getRandomManagementKey()
            }

            Button {
                text: qsTr("Copy to clipboard")
                onClicked: copyToClipboard(newManagementKeyInput.text)
            }
        }
    }

    function showPinError(title, text) {
        pinErrorDialog.title = title
        pinErrorDialog.text = text
        pinErrorDialog.open()
    }

    function showMessage(title, text) {
        messageDialog.title = title
        messageDialog.text = text
        messageDialog.open()
    }

    function getRandomManagementKey() {
        return "Very random"
    }

    function copyToClipboard(content) {
        console.log("Copy to clipboard:", content)
    }

    MessageDialog {
        id: pinErrorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok

        onAccepted: startChangePin()
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

}
