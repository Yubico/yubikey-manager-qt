import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    contentHeight: msg.implicitHeight + title.implicitHeight
    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            id: title
            text: qsTr("Error!")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
        }
        Heading2 {
            id: msg
            Layout.maximumWidth: parent.width
            text: qsTr("Failed to configure interfaces. Make sure the YubiKey does not have restricted access.")
            wrapMode: Text.WordWrap
        }
    }
    standardButtons: Dialog.Ok
}
