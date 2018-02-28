import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: resetDialog
    width: 350

    function reset() {
        device.fido_reset(handleReset)
    }

    function handleReset(err) {
        if (!err) {
            fidoResetTouch.open()
        } else {
            fidoResetError.text = err
            fidoResetError.open()
        }
    }

    Label {
        text: "Reset FIDO 2 credentials"
        font.bold: true
    }
    Label {
        text: qsTr("A reset deletes all FIDO 2 credentials on the device, including FIDO U2F credentials, and removes the PIN. The reset must triggered immediately after the YubiKey is inserted, and requires a touch on the YubiKey.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        Button {
            text: qsTr("Cancel")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            text: qsTr("Reset")
            onClicked: resetWarning.open()
        }
    }

    MessageDialog {
        id: resetWarning
        icon: StandardIcon.Warning
        title: qsTr("Reset FIDO 2?")
        text: qsTr("Are you sure you want to reset the FIDO 2 functionality? This will delete all credentials, including FIDO U2F credentials. This action cannot be undone.")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: resetDialog.reset()
    }

    MessageDialog {
        id: fidoResetError
        icon: StandardIcon.Critical
        title: qsTr("FIDO 2 reset failed.")
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: fidoResetTouch
        icon: StandardIcon.Information
        title: qsTr("Touch your YubiKey!")
        text: qsTr("Touch your YubiKey to confirm the reset.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
    }
}
