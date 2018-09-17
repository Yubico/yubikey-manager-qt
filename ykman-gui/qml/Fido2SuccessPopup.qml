import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    property string message: qsTr("Success!")

    Heading2 {
        text: message
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    standardButtons: Dialog.Ok
    onClosed: views.fido2()
}
