import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import "utils.js" as Utils

ColumnLayout {
    id: pivCertificates

    property var certificates

    signal deleteCertificate(string slotName)
    signal exportCertificate(string slotName)
    signal generateKey(string slotName)
    signal importCertificate(string slotName)

    property var certTypes: [{
            id: 'AUTHENTICATION',
            title: 'Authentication',
            description: qsTr('The X.509 Certificate for PIV Authentication and its associated private key, as defined in FIPS 201, is used to authenticate the card and the cardholder.'),
        }, {
            id: 'SIGNATURE',
            title: 'Digital Signature',
            description: qsTr('The X.509 Certificate for Digital Signature and its associated private key, as defined in FIPS 201, support the use of digital signatures for the purpose of document signing.'),
        }, {
            id: 'KEY_MANAGEMENT',
            title: 'Key Management',
            description: qsTr('The X.509 Certificate for Key Management and its associated private key, as defined in FIPS 201, support the use of encryption for the purpose of confidentiality.'),
        }, {
            id: 'CARD_AUTH',
            title: 'Card Authentication',
            description: qsTr('FIPS 201 specifies the optional Card Authentication Key (CAK) as an asymmetric or symmetric key that is used to support additional physical access applications.'),
        }]

    TabView {
        id: tabs
        Layout.fillWidth: true

        Layout.minimumHeight: Utils.maxIn(Utils.pick(contentItem.children, 'implicitHeight')) + margins * 2
        Layout.minimumWidth: Utils.maxIn(Utils.pick(contentItem.children, 'implicitWidth')) + margins * 2

        Component.onCompleted: {
            tabs.currentIndex = 1
            tabs.currentIndex = 0
        }

        Repeater {
            model: certTypes

            Tab {
                title: modelData.title
                anchors.margins: margins

                PivCertificateSlot {
                    certificate: certificates[modelData.id]
                    description: modelData.description

                    onDeleteCertificate: pivCertificates.deleteCertificate(modelData.id)
                    onExportCertificate: pivCertificates.exportCertificate(modelData.id)
                    onGenerateKey: pivCertificates.generateKey(modelData.id)
                    onImportCertificate: pivCertificates.importCertificate(modelData.id)
                }
            }
        }
    }

}
