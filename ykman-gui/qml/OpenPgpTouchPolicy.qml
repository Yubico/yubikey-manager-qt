import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("Touch Policy for OpenPGP")
    minimumWidth: 210
    modality: Qt.ApplicationModal
    id: touchDialog
    property var intialTouchValues: []

    ColumnLayout {
        GridLayout {
            columns: 2
            Label {
                text: qsTr("Authentication key:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            ComboBox {
                id: auth
                model: ['Off', 'On', 'Fixed']
            }
            Label {
                text: qsTr("Encryption key:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            ComboBox {
                id: enc
                model: ['Off', 'On', 'Fixed']
            }
            Label {
                text: qsTr("Signature key:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            ComboBox {
                id: sig
                model: ['Off', 'On', 'Fixed']
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
                onClicked: close()
            }
            Button {
                text: qsTr("Save Settings")
                enabled: (auth.enabled || enc.enabled || sig.enabled)
                         && valueHasChanged()
                onClicked: openPgpAdminPrompt.show()
            }
        }
    }
    function load() {
        device.openpgp_get_touch(function (touch) {
            intialTouchValues = touch
            auth.currentIndex = touch[0]
            enc.currentIndex = touch[1]
            sig.currentIndex = touch[2]

            // Lock UI if policy is fixed.
            auth.enabled = auth.currentIndex != 2
            enc.enabled = enc.currentIndex != 2
            sig.enabled = sig.currentIndex != 2
            show()
        })
    }

    function valueHasChanged() {
        return auth.currentIndex != intialTouchValues[0]
                || enc.currentIndex != intialTouchValues[1]
                || sig.currentIndex != intialTouchValues[2]
    }

    OpenPgpAdminPrompt {
        id: openPgpAdminPrompt
        device: yk
        onAccepted: {
            var _auth = auth.enabled ? auth.currentIndex : -1
            var _enc = enc.enabled ? enc.currentIndex : -1
            var _sig = sig.enabled ? sig.currentIndex : -1
            device.openpgp_set_touch(openPgpAdminPrompt.adminPIN, _auth, _enc,
                                     _sig, function (error) {
                                         if (!error) {
                                             openPgpAdminPrompt.close()
                                             touchDialog.close()
                                             openPgpTouchConfirm.open()
                                         } else {
                                             if (error.includes(
                                                         "Invalid PIN")) {
                                                 openPgpAdminPrompt.show()
                                                 openPgpAdminPrompt.wrongPin(
                                                             error)
                                             }
                                             // Unknown error..
                                             console.log(error)
                                         }
                                     })
        }
    }
}
