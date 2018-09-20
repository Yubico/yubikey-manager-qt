import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string message: qsTr("Success!")
    Heading2 {
        width: parent.width
        text: message
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }
    standardButtons: Dialog.Ok
}
