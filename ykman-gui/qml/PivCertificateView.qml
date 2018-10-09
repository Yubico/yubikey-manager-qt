import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: pivCertificatesView

    Component.onCompleted: load()

    function load() {// TODO: load
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Certificates")
            }

            BreadCrumbRow {
                BreadCrumb {
                    text: qsTr("Home")
                    action: views.home
                }
                BreadCrumbSeparator {
                }
                BreadCrumb {
                    text: qsTr("PIV")
                    action: views.piv
                }
                BreadCrumbSeparator {
                }
                BreadCrumb {
                    text: qsTr("Certificates")
                    active: true
                }
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
