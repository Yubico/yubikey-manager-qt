import QtQuick 2.5
import QtQuick.Dialogs 1.2

MessageDialog {

    property var device

    icon: StandardIcon.Critical
    title: qsTr("Reset PIV functionality")
    text: qsTr("Do you want to reset the PIV functionality for this YubiKey? This action will wipe all keys and certficates, and set PIN, PUK and Management Key to their default values.")
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
        device.piv_reset(function (error) {
            if (error) {
                console.log(error)
            } else {
                pivResetConfirm.open()
            }
        })
    }
    onNo: close()
}
