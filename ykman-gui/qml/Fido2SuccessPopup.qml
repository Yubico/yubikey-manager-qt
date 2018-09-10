import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

Dialog {
    width: app.width - 40
    margins: 20
    modal: true
    property string message: qsTr("Success!")

    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            text: message
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
    }
    standardButtons: Dialog.Ok
    onClosed: views.fido2()
}
