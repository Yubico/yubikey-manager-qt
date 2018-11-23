import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.platform 1.0

ColumnLayout {

    property string slot

    property bool isBusy: false
    property string busyMessage: ""

    property string algorithm: "ECCP256"
    property string expirationDate: formatDate(getDefaultExpirationDate())
    property bool selfSign: true
    property string subjectCommonName: ""

    property alias currentStep: wizardStack.depth
    readonly property int numSteps: selfSign ? 5 : 4
    readonly property string slotHex: getSlotHex(slot)
    readonly property string slotName: getSlotName(slot)

    readonly property var algorithms: yubiKey.piv ? yubiKey.piv.supported_algorithms : ["RSA1024", "RSA2048", "ECCP256", "ECCP384"]

    objectName: "pivGenerateCertificateWizard"

    function getSlotHex(slotId) {
        return yubiKey.pivSlots.find(function (slotObj) {
            return slotObj.id === slotId
        }).hex
    }

    function getSlotName(slotId) {
        return yubiKey.pivSlots.find(function (slotObj) {
            return slotObj.id === slotId
        }).name
    }

    function deleteCertificate(pin, managementKey) {
        busyMessage = qsTr("Deleting existing certificate...")
        isBusy = true
        yubiKey.pivDeleteCertificate(slot, pin, managementKey, function (resp) {
            isBusy = false
            if (resp.success) {
                pivSuccessPopup.open()
            } else {
                pivError.showResponseError(
                            resp, qsTr(
                                "Failed to delete existing certificate: %1").arg(
                                resp.message), qsTr(
                                "Failed to delete existing certificate for an unknown reason."))
            }
            views.pop()
        })
    }

    function finish(confirmOverwrite, csrFileUrl) {

        function _prompt_for_pin_and_key(pin, key) {
            if (key) {
                pivPinPopup.getPinAndThen(function (pin) {
                    _finish(pin, key)
                })
            } else {
                views.pivGetPinOrManagementKey(function (pin) {
                    _finish(pin, false)
                }, function (key) {
                    _prompt_for_pin_and_key(false, key)
                })
            }
        }

        function _finish(pin, managementKey) {
            busyMessage = qsTr("Generating...")
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
                                               callback: function (resp) {
                                                   pivError.showResponseError(
                                                               resp)
                                                   if (resp.success) {
                                                       if (selfSign) {
                                                           isBusy = false
                                                           pivSuccessPopup.open(
                                                                       )
                                                           views.pop()
                                                       } else {
                                                           deleteCertificate(
                                                                       pin,
                                                                       managementKey)
                                                       }
                                                   } else {
                                                       isBusy = false
                                                   }
                                               }
                                           })
        }

        if (confirmOverwrite || !yubiKey.pivCerts[slot]) {
            if (selfSign || csrFileUrl) {
                _prompt_for_pin_and_key()
            } else {
                selectCsrOutputDialog.open()
            }
        } else {
            var firstMessageTemplate = selfSign ? qsTr('This will overwrite the key and certificate in the %1 (%2) slot.') : qsTr('This will overwrite the key and delete the certificate in the %1 (%2) slot.')

            confirmationPopup.show([firstMessageTemplate.arg(slotName).arg(
                                        slotHex), qsTr(
                                        'This action cannot be undone!'), qsTr(
                                        'Are you sure you want to continue?')],
                                   function () {
                                       finish(true)
                                   })
        }
    }

    function formatDate(date) {
        var isoMonth = date.getMonth() + 1
        return date.getFullYear() + "-" + (isoMonth < 10 ? "0" : "") + isoMonth
                + "-" + (date.getDate() < 10 ? "0" : "") + date.getDate()
    }

    function getDefaultExpirationDate() {
        var date = new Date()
        date.setFullYear(date.getFullYear() + 1)
        return date
    }

    function isExpirationDateValid(expDate) {
        if (expDate.length !== 10) {
            return false
        }
        try {
            var parsedDate = new Date(expDate)
            return parsedDate.toISOString().substring(0, 10) === expDate && expDate >= formatDate(new Date())
        } catch (e) {
            return false
        }
    }

    function isInputValid() {
        switch (currentStep) {
        case 3:
            return !!subjectCommonName
        case 4:
            if (selfSign) {
                return isExpirationDateValid(expirationDate)
            } else {
                return true
            }
        }

        return true
    }

    function previous() {
        wizardStack.pop()
    }

    function next() {
        switch (currentStep) {
        case 1:
            wizardStack.push(algorithmView)
            break
        case 2:
            wizardStack.push(subjectView)
            break
        case 3:
            if (selfSign) {
                wizardStack.push(expirationDateView)
            } else {
                wizardStack.push(finishView)
            }
            break
        case 4:
            wizardStack.push(finishView)
            break
        }
    }

    FileDialog {
        id: selectCsrOutputDialog
        title: "Save CSR to file..."
        acceptLabel: "Save"
        defaultSuffix: ".csr"
        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["CSR files (*.csr *.pem)"]
        onAccepted: finish(true, file.toString())
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
            text: busyMessage
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
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Certificates")
                    }, {
                        text: qsTr("Generate: %1 (%2/%3)").arg(slotName).arg(
                                  currentStep).arg(numSteps)
                    }]
            }

            StackView {
                id: wizardStack
                Layout.fillHeight: true
                Layout.fillWidth: true

                initialItem: outputTypeView
            }

            Component {
                id: outputTypeView

                ColumnLayout {
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        RadioButton {
                            text: qsTr("Self-signed certificate")
                            checked: true
                            font.pixelSize: constants.h3
                            Material.foreground: yubicoBlue
                            onCheckedChanged: selfSign = checked
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Generate a self-signed certficate and store it on the YubiKey.")
                        }

                        RadioButton {
                            id: csrBtn
                            text: qsTr("Certificate Signing Request (CSR)")
                            font.pixelSize: constants.h3
                            Material.foreground: yubicoBlue
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Generate a private key on the YubiKey and output a Certificate Signing Request (CSR) to a file.")
                        }
                    }
                }
            }

            Component {
                id: algorithmView
                ColumnLayout {
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Label {
                            text: qsTr("Algorithm")
                            color: yubicoBlue
                            font.pixelSize: constants.h3
                        }

                        ComboBox {
                            id: algorithmInput
                            model: algorithms
                            currentIndex: algorithms.findIndex(function (alg) {
                                return alg === algorithm
                            })
                            Material.foreground: yubicoBlue
                            onCurrentTextChanged: algorithm = currentText
                            Layout.minimumWidth: implicitWidth + constants.contentMargins / 2
                        }
                    }
                }
            }

            Component {
                id: subjectView
                ColumnLayout {
                    Component.onCompleted: {
                        yubiKey.getUserName(function (resp) {
                            if (resp.success) {
                                if (!subjectCommonName) {
                                    subjectNameInput.text = resp.username
                                } else {
                                    subjectNameInput.text = subjectCommonName
                                }
                            }
                        })
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Label {
                            text: qsTr("Subject name")
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                        }

                        TextField {
                            id: subjectNameInput
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.fillWidth: true
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("The subject common name (CN) for the certificate.")
                            selectionColor: yubicoGreen
                            onTextChanged: subjectCommonName = text
                        }
                    }
                }
            }

            Component {
                id: expirationDateView

                ColumnLayout {

                    Component.onCompleted: calendarWidget.goToMonth(
                                               new Date(expirationDate))

                    GridLayout {
                        columns: 2

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        Label {
                            font.pixelSize: constants.h3
                            color: yubicoBlue
                            text: qsTr("Expiration date")
                        }

                        TextField {
                            text: expirationDate
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("The expiration date for the certificate, in YYYY-MM-DD format.")
                            selectionColor: yubicoGreen
                            validator: RegExpValidator {
                                regExp: /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
                            }
                            onTextChanged: {
                                var previousValue = expirationDate
                                expirationDate = text

                                if ((expirationDate.length > previousValue.length)
                                    && (expirationDate.length === 4 || expirationDate.length === 7)
                                ) {
                                    expirationDate = expirationDate + "-"
                                }
                                if (isExpirationDateValid(expirationDate)) {
                                    calendarWidget.goToMonth(new Date(expirationDate))
                                }
                            }
                        }

                        CalendarWidget {
                            id: calendarWidget
                            onDateClicked: {
                                var formatted = formatDate(date)
                                if (isExpirationDateValid(formatted)) {
                                    expirationDate = formatted
                                }
                            }

                            Layout.columnSpan: 2
                        }
                    }
                }
            }

            Component {
                id: finishView

                ColumnLayout {
                    Heading2 {
                        text: qsTr("Confirm selected options:")
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: constants.contentMargins

                        GridLayout {
                            columns: 2
                            columnSpacing: constants.contentMargins / 2
                            Layout.fillWidth: true
                            Layout.topMargin: constants.contentTopMargin
                            Label {
                                text: qsTr("Slot:")
                                font.pixelSize: constants.h3
                                font.bold: true
                                color: yubicoBlue
                            }
                            Label {
                                text: getSlotName(slot) + ' (' + getSlotHex(
                                          slot) + ')'
                                font.pixelSize: constants.h3
                                color: yubicoBlue
                            }
                            Label {
                                text: qsTr("Output format:")
                                font.pixelSize: constants.h3
                                font.bold: true
                                color: yubicoBlue
                            }
                            Label {
                                text: selfSign ? qsTr("Self-signed certificate") : qsTr(
                                                     "Certificate Signing Request (CSR)")
                                font.pixelSize: constants.h3
                                color: yubicoBlue
                            }
                            Label {
                                text: qsTr("Algorithm:")
                                font.pixelSize: constants.h3
                                font.bold: true
                                color: yubicoBlue
                            }
                            Label {
                                text: algorithm
                                font.pixelSize: constants.h3
                                color: yubicoBlue
                            }

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
                                text: qsTr("Expiration date:")
                                font.pixelSize: constants.h3
                                font.bold: true
                                color: yubicoBlue
                                visible: selfSign
                            }
                            Label {
                                text: expirationDate
                                font.pixelSize: constants.h3
                                color: yubicoBlue
                                visible: selfSign
                            }
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
                onClickedCallback: previous
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
                ToolTip.text: qsTr("Finish and generate the private key and %1").arg(
                                  selfSign ? qsTr("certificate") : qsTr("CSR"))
                enabled: isInputValid()
            }
        }
    }
}
