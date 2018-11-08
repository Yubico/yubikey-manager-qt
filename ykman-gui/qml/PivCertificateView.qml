import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: pivCertificatesView

    StackView.onActivating: load()

    function load() {// TODO: load
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Certificates")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Certificates")
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
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Digital Signature")
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Key Management")
            }
            TabButton {
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                text: qsTr("Card Authentication")
            }
        }
        StackLayout {
            currentIndex: bar.currentIndex
            Heading2 {
                text: qsTr("Authentication (9a)")
            }
            Heading2 {
                text: qsTr("Digital Signature (9c)")
            }
            Heading2 {
                text: qsTr("Key Management (9d)")
            }
            Heading2 {
                text: qsTr("Card Authentication (9e)")
            }
        }
    }
}
