import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var doneCallback

    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: doneCallback(passwordInput.text)
    onVisibleChanged: passwordInput.clear()

    function getPasswordAndThen(cb) {
        doneCallback = cb
        open()
    }

    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            text: qsTr("Password Required.")
            color: yubicoBlue
            font.pixelSize: constants.h3
        }

        RowLayout {
            Heading2 {
                text: qsTr("Password:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            TextField {
                id: passwordInput
                Layout.fillWidth: true
                background.width: width
                echoMode: TextInput.Password
                selectionColor: yubicoGreen
            }
        }
    }
}
