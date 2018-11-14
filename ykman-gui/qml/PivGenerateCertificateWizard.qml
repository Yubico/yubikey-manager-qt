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
        views.pivGetPinOrManagementKey(
            function(pin) {
                console.log("pin", pin)
            },
            function(key) {
                console.log("key", key)
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
                    Label {
                        text: "Subject"
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Expiry date"
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Advanced options"
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
