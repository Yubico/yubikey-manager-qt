import QtQuick 2.5
import QtQuick.Dialogs 1.2

MessageDialog {

    property var device

    icon: StandardIcon.Critical
    title: qsTr("Reset OpenPGP functionality")
    text: qsTr("Do you want to reset the OpenPGP functionality for this device? This action will wipe all OpenPGP data, and set all PINs to their default values.")
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
        device.openpgp_reset(function (error) {
            if (!error) {
                openPgpResetConfirm.open()
            }
        })
    }
    onNo: close()
}

