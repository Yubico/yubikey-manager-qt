import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string slot

    property bool isBusy: false
    property int stepIndex: 0
    property int highestVisitedStepIndex: 0

    readonly property bool selfSign: selfSignBtn.checked

    objectName: "pivGenerateCertificateWizard"

    onStepIndexChanged: highestVisitedStepIndex = Math.max(stepIndex, highestVisitedStepIndex)

    function finish() {
        function _finish(pin, managementKey) {
            isBusy = true
            yubiKey.pivGenerateCertificate({
                slotName: slot,
                algorithm: algorithm.currentText,
                commonName: subjectCommonName.text,
                expirationDate: expirationDate.text,
                selfSign: selfSign,
                csrFileUrl: false,
                pin: pin,
                keyHex: managementKey,
                callback: function(resp) {
                    isBusy = false
                    if (resp.success) {
                        pivSuccessPopup.open()
                        views.pop()
                    } else {
                        console.log(resp.success, resp.error, resp.message, resp.failure)
                        if (resp.message) {
                            pivError.show(resp.message)
                        }
                    }
                },
            })
        }

        views.pivGetPinOrManagementKey(
            function(pin) {
                _finish(pin, false)
            },
            function(key) {
                _finish(false, key)
            }
        );
    }

    function next() {
        stepIndex = stepIndex + 1
    }

    function previous() {
        stepIndex = stepIndex - 1
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
                text: qsTr("Generate certificate")
            }

            BreadCrumbRow {
                items: [{
                        "text": qsTr("PIV")
                    }, {
                        "text": qsTr("Certificates")
                    }, {
                        "text": qsTr("Generate")
                    }]
            }

            TabBar {
                id: tabs

                currentIndex: stepIndex
                onCurrentIndexChanged: stepIndex = currentIndex
                Layout.fillWidth: true

                Repeater {
                    model: [
                        qsTr("1. Output type"),
                        qsTr("2. Subject"),
                        qsTr("3. Expiry date"),
                        qsTr("4. Advanced options"),
                    ]

                    TabButton {
                        text: modelData
                        font.capitalization: Font.MixedCase
                        font.family: constants.fontFamily
                        Material.foreground: yubicoBlue
                        enabled: highestVisitedStepIndex >= index
                    }
                }
            }


            StackLayout {
                currentIndex: stepIndex
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                ColumnLayout {

                    Heading2 {
                        text: qsTr("Output type")
                    }

                    GridLayout {
                        columns: 2
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true

                        RadioButton {
                            id: selfSignBtn
                            text: qsTr("Self-signed certificate")
                            checked: true
                            font.pixelSize: constants.h3
                            Material.foreground: yubicoBlue
                        }

                        Label {
                            text: qsTr("Create a key on the YubiKey, generate a self-signed certificate for that key, and store it on the YubiKey.")
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        RadioButton {
                            id: csrBtn
                            text: qsTr("Certificate Signing Request")
                            font.pixelSize: constants.h3
                            Material.foreground: yubicoBlue
                        }

                        Label {
                            text: qsTr("Create a key on the YubiKey and output a Certificate Signing Request (CSR) file. The CSR can be submitted to a Certificate Authority (CA) to receive a certificate signed by that CA.")
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Subject")
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Name:")
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }

                        TextField {
                            id: subjectCommonName
                            Layout.fillWidth: true
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("The common name (CN) for the subject Distinguished Name to write into the certificate.")
                            selectionColor: yubicoGreen
                        }
                    }
                }

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Expiry date")
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Expiry date:")
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }

                        TextField {
                            id: expirationDate
                            Layout.fillWidth: true
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("The expiry date for the certificate, in YYYY-MM-DD format.")
                            selectionColor: yubicoGreen
                            validator: RegExpValidator {
                                regExp: /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
                            }
                        }
                    }
                }

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Advanced options")
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Algorithm:")
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }

                        ComboBox {
                            id: algorithm
                            model: ["RSA1024", "RSA2048", "ECCP256", "ECCP384"]
                            currentIndex: 2
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Algorithm for the private key")
                            Material.foreground: yubicoBlue
                        }
                    }
                }
            }

            CustomButton {
                text: qsTr("Authenticate")
                highlighted: true
                toolTipText: qsTr("Generate a new private key")
                onClicked: finish()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom

            BackButton {
                text: qsTr("Cancel")
            }
            Item {
                Layout.fillWidth: true
            }
            BackButton {
                onClickedHandler: previous
                visible: stepIndex > 0
            }
            NextButton {
                onClicked: next()
                visible: stepIndex < tabs.count - 1
            }
            FinishButton {
                text: qsTr("Generate")
                onClicked: finish()
                visible: stepIndex === tabs.count - 1
            }
        }
    }

}
