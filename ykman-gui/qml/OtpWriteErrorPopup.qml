import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

StandardPopup {

    heading: qsTr("Error!")

    function show() {
         messageParagraphs = [
            qsTr("Failed to modify %1.").arg(SlotUtils.slotNameCapitalized(views.selectedSlot)),
            qsTr("Make sure the YubiKey does not have restricted access."),
         ]
         open()
    }

}
