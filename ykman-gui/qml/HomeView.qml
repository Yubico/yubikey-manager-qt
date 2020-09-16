import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    objectName: "homeView"

    function getYubiKeyImageSource() {
        if (yubiKey.isYubiKey4()) {
            return "../images/yk4series.png"
        }
        if (yubiKey.isYubiKeyEdge()) {
            return "../images/ykedge.png"
        }

        if (yubiKey.isSecurityKeyNfc()) {
            return "../images/sky3.png"
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
        if (yubiKey.isYubiKeyPreview() && yubiKey.hasLightningConnector()) {
            return "../images/lightning.png"
        }
        if (yubiKey.isYubiKeyPreview()) {
            return "../images/yk5nfc.png"
        }
        if (yubiKey.isYubiKeyPlus()) {
            return "../images/ykplus.png"
        }
        if (yubiKey.isYubiKey5NFC()) {
            return "../images/yk5nfc.png"
        }
        if (yubiKey.isYubiKey5Nano()) {
            return "../images/yk5nano.png"
        }
        if (yubiKey.isYubiKey5C()) {
            return "../images/yk5c.png"
        }
        if (yubiKey.isYubiKey5CNano()) {
            return "../images/yk5cnano.png"
        }
        if (yubiKey.isYubiKey5CNFC()) {
            return "../images/yk5cnfc.png"
        }
        if (yubiKey.isYubiKey5A()) {
            return "../images/yk4.png"
        }
        if (yubiKey.isYubiKey5Ci()) {
            return "../images/yk5ci.png"
        }
        if (yubiKey.isYubiKey5Family()) {
            return "../images/yk5series.png"
        }
        return "../images/yk5series.png" //default for now
    }

    CustomContentColumn {

        Heading1 {
            text: yubiKey.name
        }
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: constants.contentWidth
            ColumnLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.leftMargin: 20
                Heading2 {
                    visible: yubiKey.version
                    text: qsTr("Firmware: ") + yubiKey.version
                }
                Heading2 {
                    visible: yubiKey.serial
                    text: qsTr("Serial: ") + yubiKey.serial
                }
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                Layout.fillWidth: true

                Image {
                    fillMode: Image.PreserveAspectFit
                    source: getYubiKeyImageSource()
                }
            }
        }
    }
}
