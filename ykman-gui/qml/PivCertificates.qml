import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import "utils.js" as Utils

ColumnLayout {

    property var certificates

    TabView {
        id: tabs
        Layout.fillWidth: true

        Layout.minimumHeight: Utils.maxIn(Utils.pick(contentItem.children, 'implicitHeight')) + 24
        Layout.minimumWidth: Utils.maxIn(Utils.pick(contentItem.children, 'implicitWidth')) + 24

        Component.onCompleted: {
            tabs.currentIndex = 1
            tabs.currentIndex = 0
        }

        Tab {
            title: "Authentication"
            anchors.margins: 12

            PivCertificateSlot {
                certificate: certificates[0x9a.toString()]
                description: qsTr("The X.509 Certificate for PIV Authentication and its associated private key, as defined in FIPS 201, is used to authenticate the card and the cardholder.")
            }
        }

        Tab {
            title: "Digital Signature"

            ColumnLayout {
                Text {
                    text: qsTr("The X.509 Certificate for Digital Signature and its associated private key, as defined in FIPS 201, support the use of digital signatures for the purpose of document signing. ")
                    wrapMode: Text.WordWrap
                }
            }
        }

        Tab {
            title: "Key Management"

            ColumnLayout {
                Text {
                    text: qsTr("The X.509 Certificate for Key Management and its associated private key, as defined in FIPS 201, support the use of encryption for the purpose of confidentiality.")
                    wrapMode: Text.WordWrap
                }
            }
        }

        Tab {
            title: "Card Authentication"

            ColumnLayout {
                Text {
                    text: qsTr("FIPS 201 specifies the optional Card Authentication Key (CAK) as an asymmetric or symmetric key that is used to support additional physical access applications. ")
                    wrapMode: Text.WordWrap
                }
            }
        }


    }

}
