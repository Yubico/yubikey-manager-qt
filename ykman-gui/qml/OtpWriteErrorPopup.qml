import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {

    Label {
        width: parent.width
        text: qsTr("Error!

Failed to modify " + SlotUtils.slotNameCapitalized(views.selectedSlot) + ".

Make sure the YubiKey does not have restricted access.")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }

    standardButtons: Dialog.Ok
}
