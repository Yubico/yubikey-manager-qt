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
            text: qsTr("Unblock PIN")
        }]
    currentPinLabel: qsTr("PUK:")
    defaultCurrentPin: '12345678'
    finishButtonText: qsTr("Unblock PIN")
    finishButtonTooltip: qsTr("Finish and unblock the PIV PIN")
    hasCurrentPin: true
    mainHeading: qsTr("Unblock PIV PIN")
    maxLength: constants.pivPinMaxLength
    minLength: constants.pivPinMinLength
    newPinTooltip: qsTr("The PIV PIN must be at least %1 characters").arg(
                       minLength)

    onChangePin: {
        yubiKey.piv_unblock_pin(currentPin, newPin, function (resp) {
            if (resp.success) {
                pivSuccessPopup.open()
                views.pop()
            } else {
                if (resp.message) {
                    pivError.show(resp.message)
                } else {
                    pivError.show(qsTr("Unknown error."))
                }
            }
        })
    }
}
