import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

Dialog {
    width: app.width - 40
    margins: 20
    modal: true
    Label {
        width: parent.width
        text: qsTr("Do you want to delete the content of the " + SlotUtils.slotNameCapitalized(
                       views.selectedSlot) + "?

This permanently deletes the configuration in the slot.")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
    }
    standardButtons: Dialog.No | Dialog.Yes
}
