import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

InlinePopup {
    Heading2 {
        width: parent.width
        text: qsTr("YubiKey Manager

Version: " + appVersion)
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
}
