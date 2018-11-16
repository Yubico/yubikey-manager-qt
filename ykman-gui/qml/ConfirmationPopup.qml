import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var acceptCallback
    property var messageParagraphs

    standardButtons: Dialog.No | Dialog.Yes

    onAccepted: acceptCallback()

    function show(msg, cb) {
        acceptCallback = cb
        if (msg instanceof String) {
            messageParagraphs = [msg]
        } else {
            messageParagraphs = msg
        }
        open()
    }

    ColumnLayout {
        width: parent.width

        Repeater {
            model: messageParagraphs

            Heading2 {
                text: modelData
                horizontalAlignment: Qt.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.maximumWidth: parent.width
            }
        }
    }
}
