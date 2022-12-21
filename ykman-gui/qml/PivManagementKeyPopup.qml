import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

AuthenticationPopup {
    property var mapLength: {3:24, 8:16, 10:24, 12:32}
    property int origKeyLength: mapLength[yubiKey.piv.key_type]
    property bool validManagementKey: (keyInput.text.length === origKeyLength*2)

    function toggleUseDefaultCurrentManagementKey() {
        if (useDefaultChkBox.checked) {
            keyInput.text = constants.pivDefaultManagementKey
        } else {
            keyInput.clear()
        }
    }

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
                enabled: !useDefaultChkBox.checked
            }

            CheckBox {
                id: useDefaultChkBox
                text: qsTr("Use default")
                checked: false
                onCheckedChanged: toggleUseDefaultCurrentManagementKey()
                font.pixelSize: constants.h3
                Material.foreground: yubicoBlue
            }
        }

        onVisibleChanged: if (visible) {
                            useDefaultChkBox.checked = false
                          }
    }
}
