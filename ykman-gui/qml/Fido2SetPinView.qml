import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("FIDO2"), qsTr("Set PIN")]
    confirmNewPinLabel: qsTr("Confirm PIN")
    finishButtonText: qsTr("Set PIN")
    finishButtonTooltip: qsTr("Finish and set the FIDO2 PIN")
    hasCurrentPin: false
    mainHeading: qsTr("Set FIDO2 PIN")
    maxLength: constants.fido2PinMaxLength
    minLength: constants.fido2PinMinLength
    newPinLabel: qsTr("New PIN")
    newPinTooltip: qsTr("The FIDO2 PIN must be at least %1 characters").arg(
                       minLength)

    onChangePin: {
        yubiKey.fidoSetPin(newPin, function (resp) {
            if (resp.success) {
                fido2SuccessPopup.open()
            } else {
                if (resp.error_id === 'too long') {
                    fido2TooLongError.open()
                } else {
                    fido2GeneralError.error = resp.error_id
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
        id: fido2GeneralError
    }
}
