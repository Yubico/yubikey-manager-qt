import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("FIDO2"), qsTr("Change PIN")]
    finishButtonTooltip: qsTr("Finish and change the FIDO2 PIN")
    hasCurrentPin: true
    mainHeading: qsTr("Change FIDO2 PIN")
    maxLength: constants.fido2PinMaxLength
    minLength: constants.fido2PinMinLength
    newPinTooltip: qsTr("The FIDO2 PIN must be at least %1 characters").arg(
                       minLength)

    onChangePin: {
        yubiKey.fidoChangePin(currentPin, newPin, function (resp) {
            if (resp.success) {
                views.fido2()
                snackbarSuccess.show("Changed FIDO2 PIN")
            } else {
                if (resp.error_id === 'too long') {
                    errorPopup.show(qsTr("Too long PIN, maximum size is 128 bytes"))
                } else if (resp.error_id === 'wrong pin') {
                    clearCurrentPinInput()
                    errorPopup.show(qsTr("The current PIN is wrong"))
                } else if (resp.error_id === 'currently blocked') {
                    errorPopup.show(qsTr("PIN authentication is currently blocked - Remove and re-insert your YubiKey"))
                } else if (resp.error_id === 'blocked') {
                    errorPopup.show(qsTr("PIN is blocked"))
                } else if (resp.error_message) {
                    errorPopup.show(resp.error_message)
                } else {
                    errorPopup.show(resp.error_id)
                }
            }
        })
    }

}
