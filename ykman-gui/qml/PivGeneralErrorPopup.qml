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

            } else if (resp.error === 'wrong_key') {
                show(qsTr("Wrong management key."))

            } else if (resp.error === 'key_required') {
                show(qsTr("Management key is required."))

            } else if (resp.error === 'wrong_pin') {
                show(qsTr('Wrong PIN, %1 tries left.').arg(resp.tries_left))

            } else if (resp.error === 'wrong_puk') {
                show(qsTr("Wrong PUK. Tries remaning: %1").arg(resp.tries_left))

            } else if (resp.error === 'blocked') {
                show(qsTr('PIN is blocked.'))

            } else if (resp.error === 'bad_format') {
                show(qsTr('Management key must be exactly %1 hexadecimal characters.').arg(constants.pivManagementKeyHexLength))

            } else if (resp.error === 'pin_required') {
                show(qsTr("PIN is required."))

            } else if (resp.error === 'new_key_bad_length' || resp.error === 'new_key_bad_hex') {
                show(qsTr('New management key must be exactly %1 hexadecimal characters.')
                    .arg(constants.pivManagementKeyHexLength))

            } else if (genericErrorMessageTemplate && resp.message) {
                console.log('PIV unmapped error:', resp.error, resp.message)
                show(genericErrorMessageTemplate.arg(resp.message))

            } else if (unknownErrorMessage) {
                console.log('PIV error:', resp.error)
                show(unknownErrorMessage)
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
