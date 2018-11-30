import QtQuick 2.9

StandardPopup {
    property var closeCallback

    heading: qsTr("Success!")
    standardButtons: Dialog.Ok

    onVisibleChanged: {
        if (!visible && closeCallback) {
            closeCallback()
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

}
