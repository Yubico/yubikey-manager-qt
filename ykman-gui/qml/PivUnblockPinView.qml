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
        yubiKey.pivUnblockPin(currentPin, newPin, function (resp) {
            if (resp.success) {
                pivSuccessPopup.open()
                views.pop()
            } else {
                pivError.showResponseError(resp)

                if (resp.error_id === 'puk_blocked') {
                    views.pop()
                } else if (resp.error_id === 'wrong_puk') {
                    clearCurrentPinInput()
                }
            }
        })
    }
}
