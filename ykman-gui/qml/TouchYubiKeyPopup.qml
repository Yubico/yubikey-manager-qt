import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

InlinePopup {
    closePolicy: Popup.NoAutoClose
    Heading2 {
        width: parent.width
        text: qsTr("Touch your YubiKey!")
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
}
