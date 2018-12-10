import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

AuthenticationPopup {

    ColumnLayout {
        width: parent.width
        spacing: 10

        Heading2 {
            text: "Please enter the PIN"
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        RowLayout {
            Heading2 {
                text: qsTr("PIN:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            TextField {
                id: keyInput
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectionColor: yubicoGreen
                onAccepted: accept()
            }
        }
    }
}
