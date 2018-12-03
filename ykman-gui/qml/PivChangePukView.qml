import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("PUK"), qsTr("Configure PINs"), qsTr("PUK")]
    codeName: qsTr("PUK")
    defaultCurrentPin: constants.pivDefaultPuk
    hasCurrentPin: true
    maxLength: constants.pivPukMaxLength
    minLength: constants.pivPukMinLength

    onChangePin: {
        yubiKey.pivChangePuk(currentPin, newPin, function (resp) {
            if (resp.success) {
                successPopup.open()
                views.pop()
            } else {
                errorPopup.showResponseError(resp, {
                                               wrong_puk: qsTr("Wrong current PUK. Tries remaning: %1").arg(
                                                              resp.tries_left)
                                           })

                if (resp.error_id === 'puk_blocked') {
                    views.pop()
                } else if (resp.error_id === 'wrong_puk') {
                    clearCurrentPinInput()
                }
            }
        })
    }
}
