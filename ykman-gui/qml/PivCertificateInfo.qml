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
        GridLayout {
            visible: !!certificate
            columns: 2
            //flow: GridLayout.TopToBottom
            Layout.fillWidth: true
            Label {
                color: yubicoBlue
                text: qsTr("Issued from:")
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: !!certificate ? certificate.issuedFrom : ''
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: qsTr("Issued to:")
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: !!certificate ? certificate.issuedTo : ''
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: qsTr("Valid from:")
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: !!certificate ? certificate.validFrom : ''
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: qsTr("Valid to:")
                font.pixelSize: constants.h3
            }
            Label {
                color: yubicoBlue
                text: !!certificate ? certificate.validTo : ''
                font.pixelSize: constants.h3
            }
        }

        Label {
            visible: !certificate
            text: qsTr("No certificate loaded.")
            color: yubicoBlue
            font.pixelSize: constants.h3
        }

        GridLayout {
            columnSpacing: 10
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            columns: 2
            CustomButton {
                enabled: !!certificate
                text: qsTr("Delete")
                iconSource: "../images/delete.svg"
                toolTipText: qsTr("Delete certificate")
            }
            CustomButton {
                Layout.fillWidth: true
                enabled: !!certificate
                text: qsTr("Export")
                iconSource: "../images/export.svg"
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
