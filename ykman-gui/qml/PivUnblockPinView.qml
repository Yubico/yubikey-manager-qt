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
                if (resp.error === 'blocked') {
                    pivError.show(qsTr("PUK is blocked."))
                    views.pop()
                } else if (resp.error === 'wrong puk') {
                    clearCurrentPinInput()
                    pivError.show(qsTr("Wrong PUK. Tries remaning: %1").arg(
                                      resp.tries_left))
                } else if (resp.message) {
                    pivError.show(
                                qsTr("PIN unblock failed for an unknown reason. Error message: %1").arg(
                                    resp.message))
                } else {
                    pivError.show(
                                qsTr("PIN unblock failed for an unknown reason."))
                }
            }
        })
    }
}
