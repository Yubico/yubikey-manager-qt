import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [{
            text: qsTr("FIDO2")
        }, {
            text: qsTr("Set PIN")
        }]
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
                successPopup.showAndThen(views.pop)
            } else {
                if (resp.error_id === 'too long') {
                    errorPopup.show(qsTr("Too long PIN, maximum size is 128 bytes"))
                } else if (resp.error_message) {
                    errorPopup.show(resp.error_message)
                } else {
                    errorPopup.show(resp.error_id)
                }
            }
        })
    }

}
