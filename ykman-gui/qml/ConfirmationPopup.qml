import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    property var acceptCallback
    standardButtons: Dialog.No | Dialog.Yes
    onAccepted: acceptCallback()

    function show(heading, message, cb) {
        confirmationHeading.text = qsTr(heading)
        confirmationLbl.text = qsTr(message)
        acceptCallback = cb
        open()
    }

    ColumnLayout {
        width: parent.width
        spacing: 10
        Heading2 {
            id: confirmationHeading
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        Label {
            id: confirmationLbl
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
            color: yubicoBlue
            Layout.maximumWidth: parent.width
            width: parent.width
        }
    }
}
