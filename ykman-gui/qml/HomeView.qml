import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "images.js" as Images

ColumnLayout {
    objectName: "homeView"

    function getYubiKeyImageSource() {
        return "../images/" + Images.getYubiKeyImageName(yubiKey) + ".png";
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
