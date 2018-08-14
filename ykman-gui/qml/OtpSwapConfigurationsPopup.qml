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
        text: qsTr("Do you want to swap the credentials between Short Touch (Slot 1) and Long Touch (Slot 2)?")
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
    }
    standardButtons: Dialog.No | Dialog.Yes
}
