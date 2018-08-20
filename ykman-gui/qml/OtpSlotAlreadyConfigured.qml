import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

Dialog {
    width: app.width - 40
    margins: 20
    modal: true
    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            text: qsTr(SlotUtils.slotNameCapitalized(
                           views.selectedSlot) + " is already configured.

Do you want to overwrite the existing configuration?")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }
    standardButtons: Dialog.No | Dialog.Yes
}
