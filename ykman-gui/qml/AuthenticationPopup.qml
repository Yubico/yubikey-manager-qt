import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var acceptCallback

    closePolicy: Popup.CloseOnEscape
    focus: true
    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: acceptCallback(keyInput.text)
    onVisibleChanged: keyInput.clear()

    function getInputAndThen(cb) {
        acceptCallback = cb
        open()
        keyInput.focus = true
    }
}
