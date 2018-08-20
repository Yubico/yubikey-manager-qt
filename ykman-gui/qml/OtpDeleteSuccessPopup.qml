import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    property string message: qsTr("Success! The configuration in " + SlotUtils.slotNameCapitalized(
                                      views.selectedSlot) + " is deleted.")

    Heading2 {
        text: message
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
    }

    standardButtons: Dialog.Ok
    onClosed: views.otp()
}
