import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.0

ColumnLayout {
    property string title
    property string slot
    property var certificate
    spacing: 15
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.fillWidth: true

    onVisibleChanged: visible ? load() : ''
    function load() {
        yubiKey.pivReadCertificate(slot, function (resp) {
            if (resp.success) {
                certificate = resp.cert
            } else {
                if (resp.error) {
                    pivError.show(resp.error)
                } else {
                    pivError.show('Failed to read certificate')
                }
            }
        })
    }

    function importCertificate(fileUrl) {

        function handleResponse(resp) {
            if (resp.success) {
                pivSuccessPopup.open()
            } else {
                if (resp.error === 'failed_parsing') {
                    pivError.show('Something went wrong with reading the file.')
                } else {
                    pivError.show(resp.error)
                }
            }
            load()
        }

        function _tryImport(password) {
            views.pivGetPinOrManagementKey(function (pin) {
                yubiKey.pivImportFile(slot, fileUrl, password, pin, null,
                                      handleResponse)
            }, function (managementKey) {
                yubiKey.pivImportFile(slot, fileUrl, password, null,
                                      managementKey, handleResponse)
            })
        }

        yubiKey.pivCanParse(fileUrl, function (resp) {
            if (resp.success) {
                _tryImport()
            } else {
                pivPasswordPopup.getPasswordAndThen(_tryImport)
            }
        })
    }

    FileDialog {
        id: selectCertificateDialog
        title: "Import from file..."
        acceptLabel: "Import"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Certificate/Key files (*.pem *.der *.pfx *.p12 *.key *.crt)"]
        onAccepted: importCertificate(file.toString())
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
            Layout.fillWidth: true

            Repeater {
                model: [
                    qsTr("Issued from:"),
                    certificate ? certificate.issuedFrom : '',
                    qsTr("Issued to:"),
                    certificate ? certificate.issuedTo : '',
                    qsTr("Valid from:"),
                    certificate ? certificate.validFrom : '',
                    qsTr("Valid to:"),
                    certificate ? certificate.validTo : '',
                ]

                Label {
                    text: modelData
                    color: yubicoBlue
                    font.pixelSize: constants.h3
                }
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
                onClicked: selectCertificateDialog.open()
            }
        }
    }
}
