import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("PIV Manager")

    property var device
    property bool hasDevice: device ? device.hasDevice : false
    minimumWidth: 500

    ColumnLayout {

        Label {
            text: (hasDevice
                ? qsTr("YubiKey present with applet version: %1").arg(device && device.piv && device.piv.version || '?')
                : qsTr("No YubiKey detected.")
            )
        }

        Button {
            text: qsTr("Change PIN")
            onClicked: changePin.open()
        }

    }

    ChangePinDialog {
        id: changePin
        codeName: 'PIN'

        onCodeChanged: {
            device.change_piv_pin(currentCode, newCode, function(result) {
                var success = result[0];
                var retries = result[1];
                if (success) {
                    showMessage(qsTr('Success'), qsTr('PIN was successfully changed.'))
                } else {
                    if (retries === null) {
                        showError(
                            qsTr('Error'),
                            qsTr('PIN change failed. This is probably a bug, please report it to the developers.')
                        )
                    } else {
                        showError(qsTr('Error'), qsTr('PIN change failed. %1 tries left.').arg(retries))
                    }
                }
            })
        }
    }

    function showError(title, text) {
        errorDialog.title = title
        errorDialog.text = text
        errorDialog.open()
    }

    function showMessage(title, text) {
        messageDialog.title = title
        messageDialog.text = text
        messageDialog.open()
    }

    MessageDialog {
        id: errorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok

        onAccepted: changePin.open()
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

    function start() {
        show()
    }

}
