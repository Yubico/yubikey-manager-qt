import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string error

    standardButtons: Dialog.Ok

    function show(message) {
        error = message
        open()
    }

    ColumnLayout {
        width: parent.width

        Heading2 {
            width: parent.width
            text: qsTr("Error!")
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
        Heading2 {
            width: parent.width
            text: error
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
    }
}
