import QtQuick 2.5
import QtQuick.Dialogs 1.2

Item {

    property var device

    MessageDialog {
        id: entry

        icon: StandardIcon.Critical
        title: qsTr("Reset PIV functionality")
        text: qsTr("Do you want to reset the PIV functionality for this YubiKey? This action will wipe all keys and certficates, and set PIN, PUK and Management Key to their default values.")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            wait.open()
            device.piv_reset(function (error) {
                wait.close()
                if (error) {
                    console.log(error)
                } else {
                    confirmation.open()
                }
            })
        }
        onNo: close()

    }

    MessageDialog {
        id: wait
        icon: StandardIcon.Information
        title: entry.title
        text: qsTr("Please wait. Do not disconnect the YubiKey.")
        standardButtons: StandardButton.NoButton
    }

    MessageDialog {
        id: confirmation
        icon: StandardIcon.Information
        title: qsTr("PIV functionality has been reset.")
        text: qsTr("All data has been cleared and default PIN, PUK and Management Key are set.")
        standardButtons: StandardButton.Ok
    }

    function open() {
        return entry.open()
    }

}
