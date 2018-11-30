import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string error

    standardButtons: Dialog.Ok

    function getDefaultMessage(resp) {
        switch (resp.error_id) {
        case 'invalid_iso8601_date':
            return qsTr('Invalid date: %1').arg(resp.date)
        case 'mgm_key_bad_format':
            return qsTr('Management key must be exactly %1 hexadecimal characters.'.arg(
                            constants.pivManagementKeyHexLength))
        case 'mgm_key_required':
            return qsTr("Management key is required.")
        case 'new_mgm_key_bad_length':
        case 'new_mgm_key_bad_hex':
            return qsTr('New management key must be exactly %1 hexadecimal characters.').arg(
                        constants.pivManagementKeyHexLength)
        case 'no_device':
            return qsTr('No YubiKey present.')
        case 'pin_blocked':
            return qsTr('PIN is blocked.')
        case 'pin_required':
            return qsTr("PIN is required.")
        case 'piv_open_failed':
            return qsTr("Failed to open the PIV application on the YubiKey.")
        case 'puk_blocked':
            return qsTr('PUK is blocked.')
        case 'wrong_mgm_key':
            return qsTr("Wrong management key.")
        case 'wrong_mgm_key_or_touch_required':
            return qsTr("Wrong management key, or timeout while waiting for touch confirmation.")
        case 'wrong_pin':
            return qsTr('Wrong PIN, %1 tries left.'.arg(resp.tries_left))
        case 'wrong_puk':
            return qsTr("Wrong PUK. Tries remaning: %1".arg(resp.tries_left))
        }
    }

    function show(message) {
        error = message
        open()
    }

    function showResponseError(resp, overrideMessages) {
        if (!resp.success) {
            if (overrideMessages && overrideMessages[resp.error_id]) {
                show(overrideMessages[resp.error_id])
            } else {
                var defaultMessage = getDefaultMessage(resp)
                if (defaultMessage) {
                    show(defaultMessage)
                } else {
                    console.log('PIV unmapped error:', resp.error_id,
                                resp.error_message)

                    if (resp.error_message) {
                        show(qsTr('Unknown error: %1').arg(resp.error_message))
                    } else {
                        show(qsTr('Unknown error. Please see the logs for details.'))
                    }
                }
            }
        }
    }

    ColumnLayout {
        width: parent.width

        Heading2 {
            width: parent.width
            text: qsTr("Error!")
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
        Heading2 {
            width: parent.width
            text: error
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
    }
}
