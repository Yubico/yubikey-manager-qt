import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var closeCallback

    property string heading: ""
    property var messageParagraphs: []

    signal setMessage(string message)
    signal setMessages(var messages)

    standardButtons: Dialog.Ok

    onSetMessage: setMessages([message])
    onSetMessages: messageParagraphs = messages

    onVisibleChanged: {
        if (!visible) {
            messageParagraphs = []

            if (closeCallback) {
                closeCallback()
            }
        }
    }

    function show(msg) {
        if (typeof msg === "string") {
            setMessage(msg)
        } else {
            setMessages(msg)
        }
        open()
    }

    function showAndThen(cb) {
        closeCallback = cb
        open()
    }

    ColumnLayout {
        width: parent.width

        Heading2 {
            text: heading
            visible: heading
            width: parent.width
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
        }

        Repeater {
            model: messageParagraphs

            Heading2 {
                horizontalAlignment: Qt.AlignHCenter
                text: modelData
                width: parent.width
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.maximumWidth: parent.width
            }
        }
    }
}
