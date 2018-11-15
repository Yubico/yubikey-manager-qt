import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.2

ColumnLayout {

    property string slot

    property bool isBusy: false

    property string algorithm: "ECCP256"
    property string csrFileUrl: ""
    property string expirationDate: ""
    property bool selfSign: true
    property string subjectCommonName: ""

    property alias currentStep: wizardStack.depth
    readonly property int numSteps: 3

    readonly property var algorithms: ["RSA1024", "RSA2048", "ECCP256", "ECCP384"]

    objectName: "pivGenerateCertificateWizard"

    function getSlotName(slotId) {
        return yubiKey.pivSlots
            .find(function(slotObj) { return slotObj.id === slotId })
            .name
    }

    function finish() {
        function _finish(pin, managementKey) {
            isBusy = true
            yubiKey.pivGenerateCertificate({
                slotName: slot,
                algorithm: algorithm,
                commonName: subjectCommonName,
                expirationDate: expirationDate,
                selfSign: selfSign,
                csrFileUrl: csrFileUrl,
                pin: pin,
                keyHex: managementKey,
                callback: function(resp) {
                    isBusy = false
                    if (resp.success) {
                        if (selfSign) {
                            pivSuccessPopup.open()
                        } else {
                            pivSuccessPopup.show(qsTr("CSR successfully written to %1").arg(csrFileUrl))
                        }
                        views.pop()
                    } else {
                        if (resp.message) {
                            pivError.show(qsTr("Failed to generate certificate: %1").arg(resp.message))
                        } else {
                            pivError.show(qsTr("Failed to generate certificate for an unknown reason."))
                        }
                    }
                },
            })
        }

        if (!selfSign && !csrFileUrl) {
            selectCsrOutputDialog.open()
        } else {
            views.pivGetPinOrManagementKey(
                function(pin) {
                    _finish(pin, false)
                },
                function(key) {
                    _finish(false, key)
                }
            );
        }
    }

    function finishCsr(fileUrl) {
        csrFileUrl = fileUrl
        finish()
    }

    function isInputValid() {
        switch (currentStep) {
        case 1:
            return !!subjectCommonName
        case 2:
            return expirationDate.length === 10
        }
    }

    function previous() {
        wizardStack.pop()
    }

    function next() {
        switch (currentStep) {
        case 1:
            wizardStack.push(expirationDateView)
            break
        case 2:
            wizardStack.push(finishView)
            break
        }
    }

    FileDialog {
        id: selectCsrOutputDialog
        title: "Please choose a destination"
        defaultSuffix: "csr"
        folder: shortcuts.documents
        selectExisting: false
        onAccepted: finishCsr(fileUrl.toString())
    }

    ColumnLayout {
        visible: isBusy
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        spacing: constants.contentMargins

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            running: visible
        }

        Heading2 {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: qsTr("Generating...")
        }
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
                        "text": qsTr("Generate: %1 (%2/%3)").arg(getSlotName(slot)).arg(currentStep).arg(numSteps)
                    }]
            }

            StackView {
                id: wizardStack
                Layout.fillHeight: true
                Layout.fillWidth: true

                initialItem: subjectView
            }

            Component {
                id: subjectView

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Subject name:")
                    }

                    TextField {
                        text: subjectCommonName
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillWidth: true
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("The common name (CN) for the subject Distinguished Name to write into the certificate.")
                        selectionColor: yubicoGreen
                        onTextChanged: subjectCommonName = text
                    }
                }
            }

            Component {
                id: expirationDateView

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Expiry date:")
                    }

                    TextField {
                        text: expirationDate
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillWidth: true
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("The expiry date for the certificate, in YYYY-MM-DD format.")
                        selectionColor: yubicoGreen
                        validator: RegExpValidator {
                            regExp: /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
                        }
                        onTextChanged: expirationDate = text
                    }
                }
            }

            Component {
                id: finishView

                RowLayout {
                    Layout.fillWidth: true
                    spacing: constants.contentMargins

                    GridLayout {
                        columns: 2
                        columnSpacing: constants.contentMargins / 2
                        Layout.fillWidth: true
                        Layout.topMargin: constants.contentTopMargin

                        Label {
                            text: qsTr("Subject name:")
                            font.pixelSize: constants.h3
                            font.bold: true
                            color: yubicoBlue
                        }
                        Label {
                            text: subjectCommonName
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }

                        Label {
                            text: qsTr("Expiry date:")
                            font.pixelSize: constants.h3
                            font.bold: true
                            color: yubicoBlue
                        }
                        Label {
                            text: expirationDate
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }
                    }


                    ColumnLayout {
                        // columns: 2
                        Layout.fillWidth: true

                        Label {
                            text: qsTr("Output format:")
                            font.pixelSize: constants.h3
                            font.bold: true
                            color: yubicoBlue
                        }

                        ColumnLayout {
                            RadioButton {
                                text: qsTr("Self-signed certificate on YubiKey")
                                checked: true
                                font.pixelSize: constants.h3
                                Material.foreground: yubicoBlue
                                onCheckedChanged: selfSign = checked
                                ToolTip.delay: 1000
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Create a key on the YubiKey, generate a self-signed certificate for that key, and store it on the YubiKey.")
                            }

                            RadioButton {
                                id: csrBtn
                                text: qsTr("CSR file")
                                font.pixelSize: constants.h3
                                Material.foreground: yubicoBlue
                                ToolTip.delay: 1000
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Create a key on the YubiKey and output a Certificate Signing Request (CSR) file.\nThe CSR must be submitted to a Certificate Authority (CA) to receive a certificate file in return, which must then be imported onto the YubiKey.")
                            }
                        }

                        Label {
                            text: qsTr("Key algorithm:")
                            font.pixelSize: constants.h3
                            font.bold: true
                            color: yubicoBlue
                            Layout.topMargin: constants.contentTopMargin
                        }

                        ComboBox {
                            id: algorithmInput
                            model: algorithms
                            currentIndex: algorithms.findIndex(function(alg) { return alg === algorithm })
                            Material.foreground: yubicoBlue
                            onCurrentTextChanged: algorithm = currentText
                            Layout.minimumWidth: implicitWidth + constants.contentMargins / 2
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom

            BackButton {
                text: qsTr("Cancel")
                iconSource: "../images/clear.svg"
            }
            Item {
                Layout.fillWidth: true
            }
            BackButton {
                onClickedHandler: previous
                visible: currentStep > 1
            }
            NextButton {
                onClicked: next()
                visible: currentStep < numSteps
                enabled: isInputValid()
            }
            FinishButton {
                text: qsTr("Generate")
                onClicked: finish()
                visible: currentStep === numSteps
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and generate the key and %1").arg(selfSign ? qsTr("certificate") : qsTr("CSR"))
            }
        }
    }

}
