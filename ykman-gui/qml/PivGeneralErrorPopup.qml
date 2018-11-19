import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string error

    standardButtons: Dialog.Ok

    function getDefaultMessage(resp) {
        switch (resp.error_id) {
        case 'bad_format':
            return qsTr('Management key must be exactly %1 hexadecimal characters.'.arg(constants.pivManagementKeyHexLength))

        case 'key_required':
            return qsTr("Management key is required.")

        case 'new_key_bad_length':
        case 'new_key_bad_hex':
            return qsTr('New management key must be exactly %1 hexadecimal characters.')
                .arg(constants.pivManagementKeyHexLength)

        case 'pin_blocked':
            return qsTr('PIN is blocked.')

        case 'pin_required':
            return qsTr("PIN is required.")

        case 'puk_blocked':
            return qsTr('PUK is blocked.')

        case 'wrong_key':
            return qsTr("Wrong management key.")

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

    function showResponseError(resp, override_messages) {
        if (!resp.success) {
            if (override_messages && override_messages[resp.error_id]) {
                show(override_messages[resp.error_id])
            } else {
                var defaultMessage = getDefaultMessage(resp)
                if (defaultMessage) {
                    show(defaultMessage)
                } else {
                    console.log('PIV unmapped error:', resp.error_id, resp.error_message)

                    if (resp.error_message) {
                        show(resp.error_message)
                    } else {
                        show('Unknown error. Please see the logs for details.')
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
