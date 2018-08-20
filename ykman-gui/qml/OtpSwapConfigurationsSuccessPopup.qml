import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    property string message: qsTr(
                                 "Success! The configurations have been swapped between the slots.")
    Heading2 {
        width: parent.width
        text: message
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }

    standardButtons: Dialog.Ok
    onClosed: views.otp()
}
