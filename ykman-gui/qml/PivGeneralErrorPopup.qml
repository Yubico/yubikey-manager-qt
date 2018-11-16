import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string error

    standardButtons: Dialog.Ok

    function show(message) {
        error = message
        open()
    }

    function showResponseError(resp, genericErrorMessageTemplate, unknownErrorMessage, messages) {
        if (!resp.success) {
            if (messages && messages[resp.error]) {
                show(messages[resp.error])
            } else {
                switch (resp.error) {
                case 'wrong_key':
                    return show(qsTr("Wrong management key."))

                case 'key_required':
                    return show(qsTr("Management key is required."))

                case 'wrong_pin':
                    return show(qsTr('Wrong PIN, %1 tries left.').arg(resp.tries_left))

                case 'wrong_puk':
                    return show(qsTr("Wrong PUK. Tries remaning: %1").arg(resp.tries_left))

                case 'blocked':
                    return show(qsTr('PIN is blocked.'))

                case 'bad_format':
                    return show(qsTr('Management key must be exactly %1 hexadecimal characters.').arg(constants.pivManagementKeyHexLength))

                case 'pin_required':
                    return show(qsTr("PIN is required."))

                case 'new_key_bad_length':
                case 'new_key_bad_hex':
                    return show(qsTr('New management key must be exactly %1 hexadecimal characters.')
                        .arg(constants.pivManagementKeyHexLength))

                default:
                    console.log('PIV unmapped error:', resp.error, resp.message)

                    if (genericErrorMessageTemplate && resp.message) {
                        show(genericErrorMessageTemplate.arg(resp.message))
                    } else if (unknownErrorMessage) {
                        show(unknownErrorMessage)
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
