import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

AuthenticationPopup {

    ColumnLayout {
        width: parent.width
        spacing: 10

        Heading2 {
            text: qsTr("Plese enter the password")
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        RowLayout {
            Heading2 {
                text: qsTr("Password:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            TextField {
                id: keyInput
                Layout.fillWidth: true
                background.width: width
                echoMode: TextInput.Password
                selectionColor: yubicoGreen
            }
        }
    }
}
