import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

Dialog {
    property string error
    width: app.width - 40
    margins: 20
    modal: true
    ColumnLayout {
        anchors.fill: parent
        Label {
            text: qsTr("Error!

Failed to configure " + SlotUtils.slotNameCapitalized(views.selectedSlot) + ".

" + error)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            color: yubicoBlue
            font.pointSize: 24
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
    }
    standardButtons: Dialog.Ok
}
