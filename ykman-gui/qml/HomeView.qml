import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

ColumnLayout {

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
        if (yubiKey.isYubiKeyPreview()) {
            return "../images/preview.png"
        }
        return "../images/yk4.png" //default for now
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: yubiKey.name
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
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
                Layout.rightMargin: 60
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Image {
                    fillMode: Image.PreserveAspectFit
                    source: getYubiKeyImageSource()
                }
            }
        }
    }
}
