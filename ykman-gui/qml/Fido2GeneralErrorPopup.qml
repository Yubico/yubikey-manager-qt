import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    property string error

    Heading2 {
        width: parent.width
        text: qsTr("Error!" + "

" + error)
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
    standardButtons: Dialog.Ok
}
