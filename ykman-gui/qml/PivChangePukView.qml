import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ChangePinView {

    breadcrumbs: [qsTr("PIV"), qsTr("Configure PINs"), qsTr("PUK")]
    codeName: qsTr("PUK")
    defaultCurrentPin: constants.pivDefaultPuk
    hasCurrentPin: true
    maxLength: constants.pivPukMaxLength
    minLength: constants.pivPukMinLength
    newPinTooltip: "The PUK must be between 6 and 8 characters long"

    onChangePin: {
        yubiKey.pivChangePuk(currentPin, newPin, function (resp) {
            if (resp.success) {
                views.pop()
                snackbarSuccess.show(qsTr("Changed PUK"))
            } else {
                snackbarError.showResponseError(resp, {
                                                    wrong_puk: qsTr("Wrong current PUK. Tries remaining: %1").arg(
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
