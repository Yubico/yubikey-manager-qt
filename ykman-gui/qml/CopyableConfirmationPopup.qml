import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var acceptCallback
    standardButtons: Dialog.Ok
    focus: true

    function show(heading, message) {
        confirmationHeading.text = heading
        confirmationLbl.text = message
        open()
    }

    ColumnLayout {
        width: parent.width
        spacing: 20
        Heading2 {
            id: confirmationHeading
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        TextInput {
            id: confirmationLbl
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
            color: yubicoBlue
            selectByMouse: true
            readOnly: true
            Layout.maximumWidth: parent.width
            width: parent.width
        }    
    }
}