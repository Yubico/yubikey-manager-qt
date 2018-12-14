import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

AuthenticationPopup {

    ColumnLayout {
        width: parent.width
        spacing: 10

        Heading2 {
            text: "Please enter the lock code"
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        RowLayout {
            Heading2 {
                text: qsTr("Lock code: ")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            CustomTextField {
                id: keyInput
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{32}$/
                }
                Layout.fillWidth: true
                echoMode: TextInput.Password
                tooltip: qsTr("Lock code must be a 32 characters (16 bytes) hex value")
                onAccepted: accept()
            }
        }
    }
}
