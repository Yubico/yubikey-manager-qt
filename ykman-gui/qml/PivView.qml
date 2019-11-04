import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: pivView

    StackView.onActivating: load()

    objectName: "pivView"

    property bool isBusy
    property bool isMacOs

    function load() {
        isBusy = true
        yubiKey.refreshPivData(function (resp) {
            isBusy = false
            if (!resp.success) {
                snackbarError.showResponseError(resp)
                views.home()
            }
            yubiKey.isMacOs(function (resp) {
                if (resp.success) {
                    isMacOs = resp.is_macos
                }
            })
        })
    }

    function getNumberOfCertsMessage() {
        var numberOfCerts = yubiKey.numberOfPivCertificates()
        if (numberOfCerts > 0) {
            return numberOfCerts + qsTr(" certificates loaded")
        } else {
            return qsTr("No certificates loaded")
        }
    }

    function resetPiv() {
        confirmationPopup.show(
                    qsTr("Reset PIV?"), qsTr(
                        "This will delete all PIV data, and restore all PINs to the default values.

This action cannot be undone!"), function () {
    isBusy = true
    yubiKey.pivReset(function (resp) {
        isBusy = false
        if (resp.success) {
            load()
            snackbarSuccess.show(qsTr("PIV application has been reset"))
        } else {
            snackbarError.showResponseError(resp)
        }
    })
})
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
                breadcrumbs: [qsTr("PIV")]
            }
            CustomButton {
                text: qsTr("Setup for macOS")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                highlighted: true
                toolTipText: qsTr("Setup PIV for pairing with macOS")
                flat: true
                iconSource: "../images/mac.svg"
                onClicked: views.pivSetupForMacOs()
                visible: isMacOs
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 30

            ColumnLayout {
                Heading2 {
                    text: qsTr("PIN Management")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h2
                }
                Label {
                    text: qsTr("PIN, PUK, Management Key")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Configure PINs")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Configure PIN, PUK and Management Key")
                    iconSource: "../images/lock.svg"
                    onClicked: views.pivPinManagement()
                }
            }

            ColumnSeparator {
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("Certificates")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: getNumberOfCertsMessage()
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Configure Certificates")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Import, export and generate PIV Certificates")
                    onClicked: views.pivCertificates()
                }
            }

            ColumnSeparator {
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("Reset")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: qsTr("Restore defaults")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Reset PIV")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Reset the PIV application")
                    iconSource: "../images/reset.svg"
                    onClicked: resetPiv()
                }
            }
        }

        ButtonsBar {
        }
    }
}
