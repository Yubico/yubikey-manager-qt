import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

Dialog {
    width: app.width - 40
    margins: 20
    modal: true
    property string message: qsTr("Success! The configuration in " + SlotUtils.slotNameCapitalized(
                                      views.selectedSlot) + " is deleted.")

    Label {
        text: message
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
        width: parent.width
    }

    standardButtons: Dialog.Ok
    onClosed: views.otp()
}
