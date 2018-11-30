import QtQuick 2.9

StandardPopup {
    heading: qsTr("Success!")
    standardButtons: Dialog.Ok

    function show(msg) {
        if (typeof msg === "string") {
            setMessage(msg)
        } else {
            setMessages(msg)
        }
        open()
    }

}
