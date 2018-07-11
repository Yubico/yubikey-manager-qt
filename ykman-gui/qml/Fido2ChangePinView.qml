import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

ColumnLayout {
    readonly property alias chosenCurrentPin: currentPin.text
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    function validPin() {
        return (pinMatches) && (chosenPin.length >= constants.fido2PinMinLength)
                && (chosenPin.length <= constants.fido2PinMaxLength)
    }

    function changePin() {
        yubiKey.fido_change_pin(chosenCurrentPin, chosenPin, function (resp) {
            if (resp.success) {
                fido2SetPinSucces.open()
            } else {
                if (resp.error === 'too long') {
                    fido2TooLongError.open()
                } else if (resp.error === 'wrong pin') {
                    fido2WrongPinError.open()
                } else if (resp.error === 'currently blocked') {
                    fido2CurrentlyBlockedError.open()
                } else if (resp.error === 'blocked') {
                    fido2BlockedError.open()
                } else {
                    fido2GeneralError.error = resp.error
                    fido2GeneralError.open()
                }
            }
        })
    }

    Fido2SuccessPopup {
        id: fido2SetPinSucces
        message: qsTr("Success! The FIDO2 PIN was changed.")
    }

    Fido2GeneralErrorPopup {
        id: fido2TooLongError
        error: qsTr("Too long PIN, maximum size is 128 bytes.")
    }

    Fido2GeneralErrorPopup {
        id: fido2WrongPinError
        error: qsTr("The current PIN is wrong.")
    }

    Fido2GeneralErrorPopup {
        id: fido2CurrentlyBlockedError
        error: qsTr("PIN authentication is currently blocked. Remove and re-insert your YubiKey.")
    }

    Fido2GeneralErrorPopup {
        id: fido2BlockedError
        error: qsTr("PIN is blocked.")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Label {
            Layout.fillWidth: true
            color: yubicoBlue
            text: qsTr("Change PIN")
            font.pointSize: 36
        }
        Label {
            text: qsTr("Current PIN")
            font.pointSize: 18
            color: yubicoBlue
        }
        TextField {
            id: currentPin
            Layout.fillWidth: true
            echoMode: TextInput.Password
        }
        Label {
            text: qsTr("New PIN")
            font.pointSize: 18
            color: yubicoBlue
        }
        TextField {
            id: newPin
            Layout.fillWidth: true
            echoMode: TextInput.Password
        }
        Label {
            text: qsTr("Confirm PIN")
            font.pointSize: 18
            color: yubicoBlue
        }
        TextField {
            id: confirmPin
            Layout.fillWidth: true
            echoMode: TextInput.Password
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            Button {
                text: qsTr("Cancel")
                onClicked: views.pop()
            }
            Button {
                enabled: validPin()
                text: qsTr("Change PIN")
                highlighted: true
                onClicked: changePin()
            }
        }
    }
}
