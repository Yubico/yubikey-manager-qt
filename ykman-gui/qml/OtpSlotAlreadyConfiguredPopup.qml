import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    Heading2 {
        width: parent.width
        text: qsTr(SlotUtils.slotNameCapitalized(
                       views.selectedSlot) + " is already configured.

Do you want to overwrite the existing configuration?")
        wrapMode: Text.WordWrap
    }
    standardButtons: Dialog.No | Dialog.Yes
}
