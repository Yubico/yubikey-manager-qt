import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    Heading2 {
        width: parent.width
        text: qsTr("Error!

Failed to configure interfaces.

Make sure the YubiKey does not have restricted access.")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
    }

    standardButtons: Dialog.Ok
}
