import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.0

ColumnLayout {
    property var slot
    property var certificate

    spacing: 15
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.fillWidth: true

    onVisibleChanged: visible ? load() : ''
    function load() {
        yubiKey.refreshPivData(function (resp) {
            if (!resp.success) {
                snackbarError.showResponseError(resp)
                views.home()
            }
        })
    }

    function deleteCertificate() {
        confirmationPopup.show(
                    "Delete certificate?",
                    "This will delete the certificate stored in slot %1, and cannot be undone. Note that the private key is not deleted.".arg(
                        slot.hex), function () {
                            function _finish(pin, managementKey) {
                                yubiKey.pivDeleteCertificate(slot.id, pin,
                                                             managementKey,
                                                             function (resp) {
                                                                 if (resp.success) {
                                                                     snackbarSuccess.show("Certificate was deleted")
                                                                 } else {
                                                                     snackbarError.showResponseError(resp)
                                                                 }
                                                             })
                            }

                            views.pivGetPinOrManagementKey(function (pin) {
                                _finish(pin, false)
                            }, function (managementKey) {
                                _finish(false, managementKey)
                            })
                        })
    }

    function exportCertificate(fileUrl) {
        yubiKey.pivExportCertificate(slot.id, fileUrl, function (resp) {
            if (resp.success) {
                snackbarSuccess.show("Certificate was exported")
            } else {
                snackbarError.showResponseError(resp)
            }
        })
    }

    function importCertificate(fileUrl) {

        function handleResponse(resp) {
            if (resp.success) {
                snackbarSuccess.show("Certificate was imported")
            } else {
                if (resp.error === 'failed_parsing') {
                    snackbarError.show(
                                'Something went wrong with reading the file.')
                } else {
                    snackbarError.show(resp.error)
                }
            }
            load()
        }

        function _tryImport(password) {
            views.pivGetPinOrManagementKey(function (pin) {
                yubiKey.pivImportFile(slot.id, fileUrl, password, pin, null,
                                      handleResponse)
            }, function (managementKey) {
                yubiKey.pivImportFile(slot.id, fileUrl, password, null,
                                      managementKey, handleResponse)
            })
        }

        yubiKey.pivCanParse(fileUrl, function (resp) {
            if (resp.success) {
                _tryImport()
            } else {
                pivPasswordPopup.getInputAndThen(_tryImport)
            }
        })
    }

    FileDialog {
        id: selectCertificateDialog
        title: "Import from file..."
        acceptLabel: "Import"
        fileMode: FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["Certificate/Key files (*.pem *.der *.pfx *.p12 *.key *.crt)"]
        onAccepted: importCertificate(file.toString())
    }

    FileDialog {
        id: exportCertificateDialog
        title: "Export certificate to file..."
        acceptLabel: "Export"
        defaultSuffix: ".crt"
        nameFilters: ["Certificate files (*.crt *.pem)"]
        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: exportCertificate(file.toString())
    }

    ColumnLayout {
        Layout.topMargin: 10
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredWidth: constants.contentWidth
        Layout.bottomMargin: -30
        Label {
            color: yubicoBlue
            font.pixelSize: constants.h2
            text: qsTr("%1 (Slot %2)").arg(slot.name).arg(slot.hex)
            Layout.preferredWidth: constants.contentWidth
        }

        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: constants.contentWidth
            GridLayout {
                visible: !!certificate
                columns: 2
                Layout.fillWidth: true
                Label {
                    text: qsTr("Issuer:")
                    color: yubicoBlue
                    font.bold: true
                    font.pixelSize: constants.h3
                }
                Label {
                    text: certificate ? certificate.issuedFrom : ''
                    color: yubicoBlue
                    font.pixelSize: constants.h3
                }
                Label {
                    text: qsTr("Subject name:")
                    color: yubicoBlue
                    font.bold: true
                    font.pixelSize: constants.h3
                }
                Label {
                    text: certificate ? certificate.issuedTo : ''
                    color: yubicoBlue
                    font.pixelSize: constants.h3
                }
                Label {
                    text: qsTr("Expiration date:")
                    color: yubicoBlue
                    font.bold: true
                    font.pixelSize: constants.h3
                }
                Label {
                    text: certificate ? certificate.validTo : ''
                    color: yubicoBlue
                    font.pixelSize: constants.h3
                }
            }

            Label {
                visible: !certificate
                text: qsTr("No certificate loaded.")
                color: yubicoGrey
                font.pixelSize: constants.h3
            }

            GridLayout {
                columnSpacing: 10
                rowSpacing: 0
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                columns: 2
                CustomButton {
                    enabled: !!certificate
                    text: qsTr("Delete")
                    iconSource: "../images/delete.svg"
                    toolTipText: qsTr("Delete certificate")
                    onClicked: deleteCertificate()
                }
                CustomButton {
                    enabled: !!certificate
                    text: qsTr("Export")
                    iconSource: "../images/export.svg"
                    highlighted: true
                    toolTipText: qsTr("Export certificate to a file")
                    onClicked: exportCertificateDialog.open()
                }
                CustomButton {
                    text: qsTr("Generate")
                    highlighted: true
                    toolTipText: qsTr("Generate a new private key")
                    onClicked: views.push(pivGenerateCertificateWizard, {
                                              slot: slot
                                          })
                }
                CustomButton {
                    text: qsTr("Import")
                    highlighted: true
                    iconSource: "../images/import.svg"
                    toolTipText: qsTr("Import certificate from a file")
                    onClicked: selectCertificateDialog.open()
                    DropArea {
                        anchors.fill: parent
                        onDropped: {
                            if (drop.hasUrls) {
                                importCertificate(drop.urls[0])
                            }
                        }
                    }
                }
            }
        }
    }
}
