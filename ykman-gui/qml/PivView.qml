import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: pivView

    StackView.onActivating: load()

    objectName: "pivView"

    property bool isBusy

    function load() {
        isBusy = true
        yubiKey.piv_list_certificates(function (resp) {
            if (!resp.error) {
                for (var i = 0; i < resp.certs.length; i++) {
                    var cert = resp.certs[i]
                    if (cert.slot === 'AUTHENTICATION') {
                        yubiKey.authenticationCert = cert
                    }
                    if (cert.slot === 'SIGNATURE') {
                        yubiKey.signatureCert = cert
                    }
                    if (cert.slot === 'KEY_MANAGEMENT') {
                        yubiKey.keyManagementCert = cert
                    }
                    if (cert.slot === 'CARD_AUTH') {
                        yubiKey.cardAuthenticationCert = cert
                    }
                }
            } else {
                console.log(resp.error)
            }
            isBusy = false
        })
    }

    function getNumberOfCertsMessage() {
        var numberOfCerts = yubiKey.numberOfPivCertificates()
        if (numberOfCerts > 0) {
            return numberOfCerts + qsTr(" certificates loaded.")
        } else {
            return qsTr("No certificates loaded.")
        }
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("PIV")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }]
            }
            RowLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                CustomButton {
                    text: qsTr("Configure PINs")
                    highlighted: true
                    flat: true
                    toolTipText: qsTr("Configure PIN, PUK and Management Key")
                    iconSource: "../images/lock.svg"
                }
                CustomButton {
                    text: qsTr("Reset PIV")
                    highlighted: true
                    toolTipText: qsTr("Reset the PIV application")
                    flat: true
                    iconSource: "../images/reset.svg"
                    onClicked: views.pivReset()
                }
                CustomButton {
                    text: qsTr("Setup for macOS")
                    highlighted: true
                    toolTipText: qsTr("Setup PIV for pairing with macOS")
                    flat: true
                    iconSource: "../images/mac.svg"
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60
            id: mainRow

            ColumnLayout {
                Heading2 {
                    text: qsTr("Initialisation")
                    font.pixelSize: constants.h2
                }
                Label {
                    text: qsTr("PIV Application is not initialised")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: qsTr("Initialise")
                    highlighted: true
                    toolTipText: qsTr("Change the default PINs and Management Key")
                }
            }

            Rectangle {
                id: separator
                Layout.minimumWidth: 1
                Layout.maximumWidth: 1
                Layout.maximumHeight: mainRow.height * 0.7
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yubicoGrey
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("Certificates")
                }
                Label {
                    text: getNumberOfCertsMessage()
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: qsTr("Handle Certificates")
                    highlighted: true
                    toolTipText: qsTr("Hande PIV Certificates")
                    onClicked: views.pivCertificates()
                }
            }
        }
    }
}
