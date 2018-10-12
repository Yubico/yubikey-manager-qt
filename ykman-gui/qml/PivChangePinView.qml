import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [{
            text: qsTr("PIV")
        }, {
            text: qsTr("Configure PINs")
        }, {
            text: qsTr("PIN")
        }]
    defaultCurrentPin: constants.pivDefaultPin
    hasCurrentPin: true
    maxLength: constants.pivPinMaxLength
    minLength: constants.pivPinMinLength

    onChangePin: {
        yubiKey.piv_change_pin(currentPin, newPin, function (resp) {
            if (resp.success) {
                pivSuccessPopup.open()
                views.pop()
            } else {
                if (resp.error === 'wrong pin') {
                    clearPinInputs()
                    pivError.show(qsTr("Wrong current PIN. Tries remaining: %1").arg(resp.tries_left))
                } else if (resp.error === 'blocked') {
                    pivError.show(qsTr("PIN is blocked. Use the PUK to unlock it, or reset the PIV application."))
                    views.pop()
                } else if (resp.error === 'incorrect parameters') {
                    clearNewPinInputs()
                    pivError.show(qsTr("Invalid PIN format. PIN must be %1 to %2 characters.").arg(minLength).arg(maxLength))
                } else {
                    pivGeneralError.error = resp.error
                    pivGeneralError.open()
                }
            }
        })
    }
}
