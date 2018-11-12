import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

ColumnLayout {
    property string title
    property string slot
    property var certificate
    spacing: 15
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.fillWidth: true

    Component.objectName: load()
    onVisibleChanged: visible ? load() : ''
    function load() {
        yubiKey.piv_read_certificate(slot, function (resp) {
            if (!resp.error) {
                certificate = resp.cert
            } else {
                console.log(resp.error)
            }
        })
    }

    Heading2 {
        text: title
        Layout.preferredWidth: constants.contentWidth
    }

    RowLayout {

        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: constants.contentWidth
        id: mainRow
        ColumnLayout {
            Layout.fillWidth: true
            Label {
                id: issuedFrom
                visible: !!certificate
                color: yubicoBlue
                text: certificate ? qsTr("Issued from: ") + certificate.issuedFrom : ''
                font.pixelSize: constants.h3
            }
            Label {
                id: issuedTo
                visible: !!certificate
                color: yubicoBlue
                text: certificate ? qsTr("Issued to: ") + certificate.issuedTo : ''
                font.pixelSize: constants.h3
            }
            Label {
                id: validFrom
                visible: !!certificate
                color: yubicoBlue
                text: certificate ? qsTr("Valid from: ") + certificate.validFrom : ''
                font.pixelSize: constants.h3
            }
            Label {
                id: validTo
                visible: !!certificate
                color: yubicoBlue
                text: certificate ? qsTr(
                                        "Valid to: ") + certificate.validTo : ''
                font.pixelSize: constants.h3
            }
            Label {
                visible: !certificate
                text: qsTr("No certficate.")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
        }

        GridLayout {
            columnSpacing: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            columns: 2
            CustomButton {
                visible: !!certificate
                text: qsTr("Delete")
                iconSource: "../images/delete.svg"
                toolTipText: qsTr("Delete certificate")
            }
            CustomButton {
                visible: !!certificate
                text: qsTr("Export")
                highlighted: true
                toolTipText: qsTr("Export certificate")
            }
            CustomButton {
                text: qsTr("Generate")
                highlighted: true
                toolTipText: qsTr("Generate a new private key")
            }
            CustomButton {
                text: qsTr("Import")
                highlighted: true
                iconSource: "../images/import.svg"
                toolTipText: qsTr("Import certificate from a file")
            }
        }
    }
}
