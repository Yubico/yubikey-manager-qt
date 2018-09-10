import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    Heading2 {
        width: parent.width
        text: qsTr("Do you want to swap the credentials between Short Touch (Slot 1) and Long Touch (Slot 2)?")
        wrapMode: Text.WordWrap
    }
    standardButtons: Dialog.No | Dialog.Yes
}
