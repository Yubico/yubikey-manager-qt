import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("PIV Manager")

    property var device
    property bool hasDevice: (device && device.hasDevice && device.piv) || false
    minimumWidth: 500

    ColumnLayout {

        Label {
            text: (hasDevice
                ? qsTr("YubiKey present with applet version: %1").arg(device && device.piv && device.piv.version || '?')
                : qsTr("No YubiKey detected.")
            )
        }

        GroupBox {
            //: PIV certificates list heading
            title: qsTr("Certificates")
            Layout.fillWidth: true

            PivCertificates {
                certificates: hasDevice ? device.piv.certificates : {}
            }
        }

        Button {
            text: qsTr("Change PIN")
            onClicked: startChangePin()
        }

    }

    ChangePinDialog {
        id: changePivPin
        codeName: 'PIN'

        onCodeChanged: {
            device.piv_change_pin(currentCode, newCode, function(result) {
                var success = result[0];
                var retries = result[1];
                if (success) {
                    showMessage(qsTr('Success'), qsTr('PIN was successfully changed.'))
                } else {
                    if (retries === null) {
                        showPinError(
                            qsTr('Error'),
                            qsTr('PIN change failed. This is probably a bug, please report it to the developers.')
                        )
                    } else {
                        showPinError(qsTr('Error'), qsTr('PIN change failed. Tries left: %1').arg(retries))
                    }
                }
            })
        }
    }

    ChangePinDialog {
        id: changePivPuk
        codeName: 'PUK'

        onCodeChanged: {
            device.piv_change_puk(currentCode, newCode, function(result) {
                var success = result[0];
                var retries = result[1];
                if (success) {
                    showMessage(qsTr('Success'), qsTr('PUK was successfully changed.'))
                } else {
                    if (retries === null) {
                        showPukError(
                            qsTr('Error'),
                            qsTr('PUK change failed. This is probably a bug, please report it to the developers.')
                        )
                    } else {
                        showPukError(qsTr('Error'), qsTr('PUK change failed. Tries left: %1').arg(retries))
                    }
                }
            })
        }
    }

    function showPinError(title, text) {
        pinErrorDialog.title = title
        pinErrorDialog.text = text
        pinErrorDialog.open()
    }

    function showPukError(title, text) {
        pukErrorDialog.title = title
        pukErrorDialog.text = text
        pukErrorDialog.open()
    }

    function showMessage(title, text) {
        messageDialog.title = title
        messageDialog.text = text
        messageDialog.open()
    }

    MessageDialog {
        id: pinErrorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok

        onAccepted: startChangePin()
    }

    MessageDialog {
        id: pukErrorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok

        onAccepted: startChangePuk()
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

    function start() {
        show()
    }

    function startChangePin() {
        changePivPin.open()
    }

    function startChangePuk() {
        changePivPuk.open()
    }

}
