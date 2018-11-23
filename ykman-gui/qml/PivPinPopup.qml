import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var doneCallback

    closePolicy: Popup.CloseOnEscape
    focus: true
    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: doneCallback(pinInput.text)
    onVisibleChanged: pinInput.clear()

    function getPinAndThen(cb) {
        doneCallback = cb
        open()
        pinInput.focus = true
    }

    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            text: qsTr("Please enter the PIN.")
            color: yubicoBlue
            font.pixelSize: constants.h3
        }

        RowLayout {
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
                onAccepted: accept()
            }
        }
    }

}
