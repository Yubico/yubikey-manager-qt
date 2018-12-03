import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("PIV"), qsTr("Configure PINs"), qsTr("PIN")]
    defaultCurrentPin: constants.pivDefaultPin
    hasCurrentPin: true
    maxLength: constants.pivPinMaxLength
    minLength: constants.pivPinMinLength

    onChangePin: {
        yubiKey.pivChangePin(currentPin, newPin, function (resp) {
            if (resp.success) {
                successPopup.open()
                views.pop()
            } else {
                errorPopup.showResponseError(resp, {
                                               wrong_pin: qsTr("Wrong current PIN. Tries remaining: %1").arg(
                                                              resp.tries_left),
                                               pin_blocked: qsTr("PIN is blocked. Use the PUK to unlock it, or reset the PIV application."),
                                               incorrect_parameters: qsTr("Invalid PIN format. PIN must be %1 to %2 characters.").arg(
                                                                         minLength).arg(
                                                                         maxLength)
                                           })

                if (resp.error_id === 'wrong_pin') {
                    clearCurrentPinInput()
                } else if (resp.error_id === 'pin_blocked') {
                    views.pop()
                } else if (resp.error_id === 'incorrect_parameters') {
                    clearNewPinInputs()
                }
            }
        })
    }
}
