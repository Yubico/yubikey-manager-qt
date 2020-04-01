import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.0

ColumnLayout {
    id: bioView

    objectName: "bioView"

    property bool isBusy
    property bool isMacOs

    function clearLogs() {
        confirmationPopup.show(
                    qsTr("Clear the logs from the device?"), qsTr(
                        "WARNING! This will delete all logs stored on the YubiKey. This action cannot be undone!

Proceed?"), function () {
    isBusy = true
    yubiKey.bioClearLogs(function (resp) {
        isBusy = false
        if (resp.success) {
            snackbarSuccess.show(qsTr("PIV application has been reset"))
        } else {
            snackbarError.showResponseError(resp)
        }
    })
})
    }


    function dumpLogs(fileUrl) {
        yubiKey.bioDumpLogs(fileUrl, function (resp) {
            if (resp.success) {
                snackbarSuccess.show(qsTr("Log has been written"))
            } else {
                snackbarError.showResponseError(resp)
            }
        })
    }

    function initiateReset() {
        reInsertYubiKey.open()
    }

    FileDialog {
        id: exportCertificateDialog
        title: "Dump logs to file..."
        defaultSuffix: ".txt"
        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: dumpLogs(file.toString())
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        RowLayout {
            ViewHeader {
                breadcrumbs: [qsTr("YubiKey Bio")]
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 30

            ColumnLayout {
                Heading2 {
                    text: qsTr("Dump logs")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    text: qsTr("Dump")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: "Dump the stored logs to a file"
                    onClicked: {
                        exportCertificateDialog.open()
                    }
                }
            }


            ColumnSeparator {
            }


            ColumnLayout {
                Heading2 {
                    text: qsTr("Clear logs")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    text: qsTr("Clear")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Clear the logs from the device")
                    onClicked: clearLogs()
                }
            }
        }

        ButtonsBar {
        }
    }
}
