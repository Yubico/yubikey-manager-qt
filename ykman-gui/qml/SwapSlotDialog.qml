import QtQuick 2.5
import QtQuick.Dialogs 1.2

MessageDialog {
    icon: StandardIcon.Warning
    title: qsTr("Swap credentials between slots")
    text: qsTr("Do you want to swap the credentials between the short press and the long press slot?")
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
        device.swap_slots(function (error) {
            if (!error) {
                confirmSwapped.open()
            } else {
                if (error === 3) {
                    writeError.open()
                }
            }
        })
    }
    onNo: close()
}
