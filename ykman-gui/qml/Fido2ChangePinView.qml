import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("FIDO2"), qsTr("Change PIN")]
    finishButtonTooltip: qsTr("Finish and change the FIDO2 PIN")
    hasCurrentPin: true
    mainHeading: qsTr("Change FIDO2 PIN")
    minLength: constants.fido2PinMinLength
    newPinTooltip: qsTr("The FIDO2 PIN must be at least %1 characters").arg(
                       minLength)

    onChangePin: {
        yubiKey.fidoChangePin(currentPin, newPin, function (resp) {
            if (resp.success) {
                views.fido2()
                snackbarSuccess.show(qsTr("Changed FIDO2 PIN"))
            } else {
                if (resp.error_id === 'too long') {
                    snackbarError.show(qsTr("Too long PIN"))
                } else if (resp.error_id === 'wrong pin') {
                    clearCurrentPinInput()
                    snackbarError.show(qsTr("The current PIN is wrong"))
                } else if (resp.error_id === 'currently blocked') {
                    snackbarError.show(
                                qsTr("PIN authentication is currently blocked. Remove and re-insert your YubiKey"))
                } else if (resp.error_id === 'blocked') {
                    snackbarError.show(qsTr("PIN is blocked"))
                } else if (resp.error_message) {
                    snackbarError.show(resp.error_message)
                } else {
                    snackbarError.show(resp.error_id)
                }
            }
        })
    }
}
