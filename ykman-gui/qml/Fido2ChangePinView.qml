import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [{
            text: qsTr("FIDO2")
        }, {
            text: qsTr("Change PIN")
        }]
    finishButtonTooltip: qsTr("Finish and change the FIDO2 PIN")
    hasCurrentPin: true
    mainHeading: qsTr("Change FIDO2 PIN")
    maxLength: constants.fido2PinMaxLength
    minLength: constants.fido2PinMinLength
    newPinTooltip: qsTr("The FIDO2 PIN must be at least %1 characters").arg(
                       minLength)

    onChangePin: {
        yubiKey.fido_change_pin(currentPin, newPin, function (resp) {
            if (resp.success) {
                fido2SuccessPopup.open()
            } else {
                if (resp.error === 'too long') {
                    fido2TooLongError.open()
                } else if (resp.error === 'wrong pin') {
                    clearCurrentPinInput()
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

    Fido2GeneralErrorPopup {
        id: fido2TooLongError
        error: qsTr("Too long PIN, maximum size is 128 bytes")
    }

    Fido2GeneralErrorPopup {
        id: fido2WrongPinError
        error: qsTr("The current PIN is wrong")
    }

    Fido2GeneralErrorPopup {
        id: fido2CurrentlyBlockedError
        error: qsTr("PIN authentication is currently blocked - Remove and re-insert your YubiKey")
    }

    Fido2GeneralErrorPopup {
        id: fido2BlockedError
        error: qsTr("PIN is blocked")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
    }
}
