import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

EnterPinView {

    breadcrumbs: [qsTr("FIDO2"), qsTr("Enter PIN")]
    finishButtonText: qsTr("Enter PIN")
    finishButtonTooltip: qsTr("Finish and enter the FIDO2 PIN")
    hasCurrentPin: false
    mainHeading: qsTr("Enter FIDO2 PIN")
    minLength: constants.fido2PinMinLength

    property bool enteredPin : false

    onChangePin: {
        yubiKey.fidoEnterPin(newPin, function (resp) {
            if (resp.success) {
                snackbarSuccess.show(qsTr("Entered FIDO2 PIN"))
                enroll.enroll()
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

    Fido2EnrollView {
        id: enroll
    }
}


