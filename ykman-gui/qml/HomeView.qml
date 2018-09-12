import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    objectName: "homeview"

    function getYubiKeyImageSource() {
        if (yubiKey.isYubiKey4()) {
            return "../images/yk4series.png"
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
        return "../images/yk4series.png" //default for now
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: constants.contentMargins
        Layout.topMargin: constants.contentTopMargin
        Layout.bottomMargin: constants.contentBottomMargin
        Layout.preferredHeight: constants.contentHeight
        Layout.maximumHeight: constants.contentHeight
        Layout.preferredWidth: constants.contentWidth
        Layout.maximumWidth: constants.contentWidth

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
