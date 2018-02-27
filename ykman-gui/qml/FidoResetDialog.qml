import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ColumnLayout {
    width: 350
    Label {
        text: "Reset FIDO 2 credentials"
        font.bold: true
    }
    Label {
        text: qsTr("A reset deletes all FIDO credentials on the device, and removes the PIN. The reset must triggered within 10 seconds after the YubiKey is inserted in the USB port, and requires a touch on the YubiKey.")
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
            onClicked: reset()
        }
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
}
