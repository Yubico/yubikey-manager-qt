import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("PIN Retries for OpenPGP")
    id: opgpPinRetriesDialog
    minimumWidth: 250
    modality: Qt.ApplicationModal

    ColumnLayout {

        GridLayout {
            columns: 2
            Label {
                text: qsTr("PIN:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            SpinBox {
                id: pinRetries
                Layout.fillWidth: true
                value: 3
                maximumValue: 99
                minimumValue: 1
            }
            Label {
                text: qsTr("Reset Code:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            SpinBox {
                id: resetCodeRetries
                Layout.fillWidth: true
                value: 3
                maximumValue: 99
                minimumValue: 1
            }
            Label {
                text: qsTr("Admin PIN:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            SpinBox {
                id: adminPinRetries
                Layout.fillWidth: true
                value: 3
                maximumValue: 99
                minimumValue: 1
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
                onClicked: clearsPinWhenSettingPinRetries(
                               ) ? openPgpClearPinWarning.open(
                                       ) : openPgpAdminPrompt.show()
            }
        }
    }

    MessageDialog {
        id: openPgpClearPinWarning
        icon: StandardIcon.Warning
        title: qsTr("PIN values will be reset!")
        text: qsTr("Setting PIN retries will reset the values for all 3 PINs!")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: openPgpAdminPrompt.show()
    }

    OpenPgpAdminPrompt {
        id: openPgpAdminPrompt
        device: yk
        onAccepted: setPinRetries()
    }

    function setPinRetries() {
        device.openpgp_set_pin_retries(openPgpAdminPrompt.adminPIN,
                                       pinRetries.value,
                                       resetCodeRetries.value,
                                       adminPinRetries.value, function (error) {
                                           if (!error) {
                                               openPgpAdminPrompt.close()
                                               opgpPinRetriesDialog.close()
                                               openPgpPinRetriesConfirm.open()
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
