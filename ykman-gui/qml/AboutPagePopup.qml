import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    ColumnLayout {
        Heading2 {
            text: qsTr("YubiKey Manager")
        }
        Label {
            font.pixelSize: constants.h3
            color: yubicoBlue
            text: qsTr("Version: " + appVersion)
        }
    }
}
