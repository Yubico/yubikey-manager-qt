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
    defaultCurrentPin: constants.pivDefaultPuk
    finishButtonText: qsTr("Unblock PIN")
    finishButtonTooltip: qsTr("Finish and unblock the PIN")
    hasCurrentPin: true
    mainHeading: qsTr("Unblock PIN")
    maxLength: constants.pivPinMaxLength
    minLength: constants.pivPinMinLength

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
