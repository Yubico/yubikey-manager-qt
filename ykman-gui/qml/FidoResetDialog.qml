import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: resetDialog
    Keys.onTabPressed: cancelBtn.forceActiveFocus()
    Keys.onEscapePressed: close()

    function reset() {
        device.fido_reset(handleReset)
    }

    function handleReset(err) {
        //TODO: Show touch prompt
        if (!err) {
            fidoResetSuccess.open()
        } else {
            fidoResetError.open()
        }
    }

    Label {
        text: "Reset FIDO Module"
        font.bold: true
    }
    Label {
        text: qsTr("Resetting FIDO permanently erases all FIDO credentials on the device - U2F (FIDO 1) & FIDO 2.

The FIDO PIN is also cleared.

The reset must be performed within 5 seconds after the YubiKey is inserted, and requires a touch on the YubiKey.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        Button {
            id: cancelBtn
            KeyNavigation.tab: resetBtn
            text: qsTr("Cancel")
            isDefault: true
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            id: resetBtn
            KeyNavigation.tab: cancelBtn
            text: qsTr("Reset")
            onClicked: resetWarning.open()
        }
    }

    MessageDialog {
        id: resetWarning
        icon: StandardIcon.Warning
        title: qsTr("Reset FIDO 2?")
        text: qsTr("Are you sure you want to reset the FIDO 2 functionality?

This will delete all FIDO credentials, including FIDO U2F credentials.

This action cannot be undone!")
        standardButtons: StandardButton.Yes | StandardButton.No
        onAccepted: resetDialog.reset()
    }

    MessageDialog {
        id: fidoResetError
        icon: StandardIcon.Critical
        title: qsTr("Error!")
        text: qsTr("Resetting the FIDO Module failed.

The reset must be performed within 5 seconds after the YubiKey is inserted in the USB port.")
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: fidoResetSuccess
        icon: StandardIcon.Information
        title: qsTr("Success!")
        text: qsTr("The FIDO Module reset was successful.

All FIDO credentials and the FIDO PIN were permanently deleted.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
    }

    MessageDialog {
        id: fidoResetTouch
        icon: StandardIcon.Information
        title: qsTr("Touch your YubiKey!")
        text: qsTr("Touch your YubiKey to confirm the reset.")
    }
}
