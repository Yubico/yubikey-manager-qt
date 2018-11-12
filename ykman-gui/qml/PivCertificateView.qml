import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

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
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Authentication")
                Material.foreground: yubicoBlue
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Digital Signature")
                Material.foreground: yubicoBlue
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Key Management")
                Material.foreground: yubicoBlue
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Card Authentication")
                Material.foreground: yubicoBlue
            }
        }

        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            currentIndex: bar.currentIndex
            PivCertificateInfo {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                title: qsTr("Authentication (Slot 9a)")
                slot: 'AUTHENTICATION'
                certificate: yubiKey.authenticationCert
            }
            PivCertificateInfo {
                title: qsTr("Digital Signature (Slot 9c)")
                slot: 'SIGNATURE'
                certificate: yubiKey.signatureCert
            }
            PivCertificateInfo {
                title: qsTr("Key Management (Slot 9d)")
                slot: 'KEY_MANAGEMENT'
                certificate: yubiKey.keyManagementCert
            }
            PivCertificateInfo {
                title: qsTr("Card Authentication (Slot 9e)")
                slot: 'CARD_AUTH'
                certificate: yubiKey.cardAuthenticationCert
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            BackButton {
            }
        }
    }
}
