import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils

InlinePopup {

    property var pinCallback
    property var keyCallback

    readonly property bool usingPin: (yubiKey.piv || {}).has_protected_key || false

    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: {
        if (usingPin) {
            pinCallback(pinInput.text)
        } else {
            keyCallback(keyInput.text)
        }
    }
    onVisibleChanged: {
        pinInput.clear()
        keyInput.clear()
    }

    function getAndThen(pinCb, keyCb) {
        pinCallback = pinCb
        keyCallback = keyCb
        open()
    }

    ColumnLayout {
        anchors.fill: parent

        Heading2 {
            text: qsTr("Please enter the PIN.")
            color: yubicoBlue
            font.pixelSize: constants.h3
            visible: usingPin
        }

        RowLayout {
            visible: usingPin

            Heading2 {
                text: qsTr("PIN:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            TextField {
                id: pinInput
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectionColor: yubicoGreen
            }
        }

        Heading2 {
            text: qsTr("Please enter the management key.")
            color: yubicoBlue
            font.pixelSize: constants.h3
            visible: !usingPin
        }

        RowLayout {
            visible: !usingPin

            Heading2 {
                text: qsTr("Management key:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            PivManagementKeyTextField {
                id: keyInput
                Layout.fillWidth: true
            }
        }
    }
}
