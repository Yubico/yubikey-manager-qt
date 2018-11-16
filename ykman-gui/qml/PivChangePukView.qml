import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [{
            text: qsTr("PUK")
        }, {
            text: qsTr("Configure PINs")
        }, {
            text: qsTr("PUK")
        }]
    codeName: qsTr("PUK")
    defaultCurrentPin: constants.pivDefaultPuk
    hasCurrentPin: true
    maxLength: constants.pivPukMaxLength
    minLength: constants.pivPukMinLength

    onChangePin: {
        yubiKey.pivChangePuk(currentPin, newPin, function (resp) {
            if (resp.success) {
                pivSuccessPopup.open()
                views.pop()
            } else {
                if (resp.error === 'blocked') {
                    pivError.show(qsTr("PUK is blocked."))
                    views.pop()
                } else if (resp.error === 'wrong puk') {
                    clearCurrentPinInput()
                    pivError.show(
                                qsTr("Wrong current PUK. Tries remaning: %1").arg(
                                    resp.tries_left))
                } else if (resp.message) {
                    pivError.show(
                                qsTr("PUK change failed for an unknown reason. Error message: %1").arg(
                                    resp.message))
                } else {
                    pivError.show(
                                qsTr(
                                    "PUK change failed for an unknown reason."))
                }
            }
        })
    }
}
