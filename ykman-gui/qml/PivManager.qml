import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("PIV Manager")

    property var device
    readonly property var yk: device // Needed so that we can pass `device: yk` to subcomponents
    property bool hasDevice: (device && device.hasDevice && device.piv) || false
    readonly property var certificates: hasDevice && device.piv.certificates || {}
    readonly property int numCerts: Object.keys(certificates).length

    minimumWidth: 500

    ColumnLayout {

        Label {
            text: (hasDevice
                ? qsTr("YubiKey present with applet version: %1").arg(device && device.piv && device.piv.version || '?')
                : qsTr("No YubiKey detected.")
            )
        }

        Label {
            //: PIV certificates list heading
            text: qsTr("Certificates: %1").arg(numCerts)
            Layout.fillWidth: true
        }

        PivCertificates {
            certificates: hasDevice ? device.piv.certificates : {}

            onExportCertificate: {
                exportFileDialog.slotName = slotName
                exportFileDialog.open()
            }

            FileDialog {
                property string slotName

                id: exportFileDialog
                title: 'Select export destination file'
                selectExisting: false
                defaultSuffix: 'pem'
                nameFilters: [ 'Certificate files (*.pem)', 'All files (*)']

                onAccepted: {
                    device.piv_export_certificate(slotName, fileUrls[0], function(result) {
                    })
                }
            }
        }

        Button {
            text: qsTr("Change PIN")
            onClicked: startChangePin()
        }

        Button {
            text: qsTr("Change PUK")
            onClicked: startChangePuk()
        }

    }

    ChangePinDialog {
        id: changePivPin
        codeName: 'PIN'

        onCodeChanged: {
            device.piv_change_pin(currentCode, newCode, function(result) {
                if (result.success) {
                    showMessage(qsTr('Success'), qsTr('PIN was successfully changed.'))
                } else {
                    if (result.tries_left === null) {
                        showPinError(
                            qsTr('Error'),
                            qsTr('PIN change failed. This is probably a bug, please report it to the developers.')
                        )
                    } else {
                        showPinError(qsTr('Error'), qsTr('PIN change failed. Tries left: %1').arg(result.tries_left))
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
                if (result.success) {
                    showMessage(qsTr('Success'), qsTr('PUK was successfully changed.'))
                } else {
                    if (result.tries_left === null) {
                        showPukError(
                            qsTr('Error'),
                            qsTr('PUK change failed. This is probably a bug, please report it to the developers.')
                        )
                    } else {
                        showPukError(qsTr('Error'), qsTr('PUK change failed. Tries left: %1').arg(result.tries_left))
                    }
                }
            })
        }
    }

    DefaultDialog {
        id: changePivManagementKeyDialog

        PivSetManagementKeyForm {
            id: pivSetManagementKeyForm
            device: yk
            onChangeSuccessful: changePivManagementKeyDialog.hide()
        }
    }

    PivResetDialog {
        id: pivResetDialog
        device: yk
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

    function startChangeManagementKey() {
        changePivManagementKeyDialog.show()
    }

    function startReset() {
        pivResetDialog.open()
    }

}
