import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

InlinePopup {
    Label {
        width: parent.width
        text: qsTr("YubiKey Manager

Version: " + appVersion)
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
}
