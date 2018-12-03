import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

StandardPopup {

    property var acceptCallback

    standardButtons: Dialog.No | Dialog.Yes

    onAccepted: acceptCallback()

    function show(msg, cb) {
        acceptCallback = cb
        if (typeof msg === "string") {
            setMessage(msg)
        } else {
            setMessages(msg)
        }
        open()
    }

}
