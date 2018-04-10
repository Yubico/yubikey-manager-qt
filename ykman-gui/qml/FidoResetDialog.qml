import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: resetDialog
    Keys.onTabPressed: cancelBtn.forceActiveFocus()
    Keys.onEscapePressed: close()

    function handleResetResponse(resp) {
        fidoResetTouch.close()
        if (resp.success) {
            fidoResetSuccess.open()
        } else {
            fidoResetError.open()
        }
    }

    Label {
        text: "Reset FIDO Applications"
        font.bold: true
    }

    Label {
        text: qsTr("Resetting FIDO permanently erases all FIDO credentials on the device - U2F & FIDO2.

The FIDO PIN is also cleared.

The reset must be performed within 5 seconds after the YubiKey is inserted, and requires a touch on the YubiKey.")
        Layout.fillWidth: true
        Layout.maximumWidth: resetDialog.width
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
        title: qsTr("Reset FIDO2?")
        text: qsTr("Are you sure you want to reset the FIDO Applications?

This will delete all FIDO credentials, including FIDO U2F credentials.

This action cannot be undone!")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: reInsertPrompt.open()
    }

    MessageDialog {
        id: fidoResetError
        icon: StandardIcon.Critical
        title: qsTr("Error!")
        text: qsTr("Resetting the FIDO Applications failed.

You must confirm the reset by touching your YubiKey.")
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: fidoResetSuccess
        icon: StandardIcon.Information
        title: qsTr("Success!")
        text: qsTr("The reset of the FIDO Applications was successful.

All FIDO credentials and the FIDO PIN were permanently deleted.")
        onAccepted: fidoDialog.load()
    }

    MessageDialog {
        id: reInsertPrompt
        readonly property bool hasDevice: device.hasDevice
        property bool loadedReset
        icon: StandardIcon.Information
        title: qsTr("Remove and re-insert your YubiKey!")
        text: qsTr("Remove and re-insert your YubiKey to perform the reset.")
        standardButtons: StandardButton.NoButton
        onHasDeviceChanged: resetOnReInsert()
        function resetOnReInsert() {
            if (!hasDevice) {
                loadedReset = true
            } else {
                if (loadedReset) {
                    loadedReset = false
                    device.fido_reset(handleResetResponse)
                    reInsertPrompt.close()
                    fidoResetTouch.open()
                }
            }
        }
    }

    MessageDialog {
        id: fidoResetTouch
        icon: StandardIcon.Information
        title: qsTr("Touch your YubiKey!")
        text: qsTr("Touch your YubiKey to confirm the reset.")
        standardButtons: StandardButton.NoButton
    }
}
