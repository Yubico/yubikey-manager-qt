import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

RowLayout {

    function getYubiKeyImageSource() {
        if (yubiKey.isYubiKey4()) {
            return "../images/yk4.png"
        }
        if (yubiKey.isSecurityKeyByYubico()) {
            return "../images/sky2.png"
        }
        if (yubiKey.isFidoU2fSecurityKey()) {
            return "../images/sky1.png"
        }
        if (yubiKey.isNEO()) {
            return "../images/neo.png"
        }
        if (yubiKey.isYubiKeyStandard()) {
            return "../images/standard.png"
        }
        return "../images/yk4.png" //default for now
    }

    ColumnLayout {
        Layout.margins: 20
        ColumnLayout {
            Label {
                text: yubiKey.name
                font.pointSize: constants.h2
                color: yubicoBlue
            }
            Label {
                visible: yubiKey.version
                color: yubicoBlue
                font.pointSize: constants.h2
                text: qsTr("Firmware: ") + yubiKey.version
            }
            Label {
                visible: yubiKey.serial
                color: yubicoBlue
                font.pointSize: constants.h2
                text: qsTr("Serial: ") + yubiKey.serial
            }
        }
    }
    ColumnLayout {
        Image {
            antialiasing: false
            fillMode: Image.PreserveAspectFit
            source: getYubiKeyImageSource()
        }
    }
}
