import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import "utils.js" as Utils

ColumnLayout {
    id: pivCertificatesView

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Certificates")
            }

            BreadCrumbRow {
                items: [{
                        "text": qsTr("PIV")
                    }, {
                        "text": qsTr("Certificates")
                    }]
            }
        }

        TabBar {
            id: bar
            Layout.fillWidth: true
            Repeater {
                model: Utils.pick(yubiKey.pivSlots, "name")

                TabButton {
                    text: modelData
                    font.capitalization: Font.MixedCase
                    font.family: constants.fontFamily
                    Material.foreground: yubicoBlue
                }
            }
        }

        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            currentIndex: bar.currentIndex

            Repeater {
                model: yubiKey.pivSlots

                PivCertificateInfo {
                    slot: modelData
                    certificate: yubiKey.pivCerts[modelData.id]
                }
            }
        }
        BackButton {
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            flat: true
        }
    }
}
