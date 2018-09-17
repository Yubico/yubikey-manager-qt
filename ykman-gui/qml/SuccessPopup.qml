import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Dialog {
    property string message: qsTr("Success!")
    modal: true
    x: (parent.width - width) / 2
    width: 300
    Heading2 {
        width: parent.width
        text: message
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }
    standardButtons: Dialog.Ok
}
