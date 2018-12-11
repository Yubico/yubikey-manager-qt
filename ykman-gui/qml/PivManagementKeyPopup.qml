import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

AuthenticationPopup {
    ColumnLayout {
        width: parent.width
        spacing: 10

        Heading2 {
            text: "Please enter the management key"
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        RowLayout {

            Heading2 {
                text: qsTr("Management key")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }

            PivManagementKeyTextField {
                id: keyInput
                background.width: width
                Layout.fillWidth: true
                onAccepted: accept()
            }
        }
    }
}
