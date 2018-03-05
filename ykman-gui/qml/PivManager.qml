import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    height: calculateHeight()
    minimumHeight: calculateHeight()
    minimumWidth: calculateWidth()
    width: minimumWidth
    title: qsTr("PIV Manager")

    property var device
    readonly property var yk: device // Needed so that we can pass `device: yk` to subcomponents
    property bool hasDevice: (device && device.hasDevice && device.piv) || false
    readonly property var certificates: hasDevice && device.piv.certificates || {}
    readonly property int numCerts: Object.keys(certificates).length
    property string selectedSlotName: ''

    function calculateHeight() {
        var stackItem = stack.currentItem
        var doubleMargins = margins * 2
        return stackItem ? stackItem.implicitHeight + doubleMargins : 0
    }

    function calculateWidth() {
        var stackItem = stack.currentItem
        var doubleMargins = margins * 2
        return stackItem ? stackItem.implicitWidth + doubleMargins : 0
    }

    function push(item) {
        stack.push({
            item: item,
            immediate: true,
        })
    }

    function pop() {
        stack.pop({ immediate: true })
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: overview
    }

    Component {
        id: overview

        ColumnLayout {

            Label {
                text: (hasDevice
                    ? qsTr("YubiKey present with applet version: %1").arg(device && device.piv && device.piv.version || '?')
                    : qsTr("No YubiKey detected.")
                )
            }

            Label {
                //: PIV certificates list heading
                text: qsTr("Certificates: %1").arg(numCerts)
                Layout.fillWidth: true
            }

            PivCertificates {
                certificates: hasDevice ? device.piv.certificates : {}

                onDeleteCertificate: {
                    device.piv_delete_certificate({
                        slotName: slotName,
                        callback: function(result) {
                            if (!result.success) {
                                showError('Delete failed', 'Failed to delete certificate: ' + (result.message || 'unknown error.'))
                            }
                        },
                        pinCallback: askPin,
                        keyCallback: askManagementKey,
                        touchCallback: function() {
                            touchYubiKeyPrompt.show()
                        },
                    })
                }

                onExportCertificate: {
                    exportFileDialog.slotName = slotName
                    exportFileDialog.open()
                }

                onGenerateKey: {
                    selectedSlotName = slotName
                    push(generateKeyView)
                }

                onImportCertificate: {
                    selectedSlotName = slotName
                    push(importView)
                }

                FileDialog {
                    property string slotName

                    id: exportFileDialog
                    title: 'Select export destination file'
                    selectExisting: false
                    defaultSuffix: 'pem'
                    nameFilters: [ 'Certificate files (*.pem)', 'All files (*)']

                    onAccepted: {
                        device.piv_export_certificate(slotName, fileUrls[0], function(result) {
                        })
                    }
                }

            }

            Button {
                text: qsTr("Change PIN")
                onClicked: startChangePin()
            }

        }
    }

    Component {
        id: generateKeyView

        PivGenerateKeyView {
            slotName: selectedSlotName
            onAccepted: {
                device.piv_generate_certificate({
                    slotName: slotName,
                    algorithm: algorithm,
                    csrFileUrl: csrFileUrl,
                    expirationDate: expirationDate,
                    pinPolicy: pinPolicy,
                    selfSign: selfSign,
                    subjectDn: subjectDn,
                    touchPolicy: touchPolicy,
                    callback: function(result) {
                        if (result.success) {
                            closed()
                        } else if (result.failure.permissionDenied) {
                            showError('Permission denied', 'Permission to write CSR to ' + csrFileUrl + ' was denied.')
                        } else {
                            showError('Generate failed', 'Failed to generate certificate: ' + (result.message || 'unknown error.'))
                        }
                    },
                    pinCallback: askPin,
                    keyCallback: askManagementKey,
                    touchCallback: function() {
                        touchYubiKeyPrompt.show()
                    },
                })
            }
            onClosed: pop()
        }
    }

    Component {
        id: importView

        PivImportView {

            function importCertificate(certificateFileUrl) {

                device.piv_import_certificate({
                    slotName: selectedSlotName,
                    fileUrl: certificateFileUrl,
                    callback: function(result) {
                        if (result.success) {
                            closed()
                        } else {
                            showError('Import failed', 'Failed to import certificate: ' + (result.message || 'unknown error.'))
                        }
                    },
                    pinCallback: askPin,
                    keyCallback: askManagementKey,
                    touchCallback: function() {
                        touchYubiKeyPrompt.show()
                    },
                })
            }

            function importKey(keyFileUrl, pinPolicy, touchPolicy) {
                device.piv_import_key({
                    slotName: selectedSlotName,
                    fileUrl: keyFileUrl,
                    pinPolicy: pinPolicy,
                    touchPolicy: touchPolicy,
                    callback: function(result) {
                        if (result.success) {
                            closed()
                        } else if (result.failure.supportedPinPolicies) {
                            if (result.failure.supportedPinPolicies.length === 0) {
                                showError('Import failed', 'Failed to import key. This YubiKey does not support PIN policies.')
                            } else {
                                showError(
                                    'Import failed',
                                    'Failed to import key. This YubiKey supports only the following PIN policies: ' + result.failure.supportedPinPolicies.join(', ')
                                )
                            }
                        } else if (result.failure.supportedTouchPolicies) {
                            if (result.failure.supportedTouchPolicies.length === 0) {
                                showError('Import failed', 'Failed to import key. This YubiKey does not support touch policies.')
                            } else {
                                showError(
                                    'Import failed',
                                    'Failed to import key. This YubiKey supports only the following touch policies: ' + result.failure.supportedTouchPolicies.join(', ')
                                )
                            }
                        } else {
                            showError('Import failed', 'Failed to import key: ' + (result.message || 'unknown error.'))
                        }
                    },
                    pinCallback: askPin,
                    keyCallback: askManagementKey,
                    touchCallback: function() {
                        touchYubiKeyPrompt.show()
                    },
                })
            }

            onClosed: pop()
            onImportCertificateAccepted: importCertificate(certificateFileUrl)
            onImportKeyAccepted: importKey(keyFileUrl, pinPolicy, touchPolicy)
        }
    }

    ChangePinDialog {
        id: changePivPin
        codeName: 'PIN'

        onCodeChanged: {
            device.piv_change_pin(currentCode, newCode, function(result) {
                var success = result[0];
                var retries = result[1];
                if (success) {
                    showMessage(qsTr('Success'), qsTr('PIN was successfully changed.'))
                } else {
                    if (retries === null) {
                        showError(
                            qsTr('Error'),
                            qsTr('PIN change failed. This is probably a bug, please report it to the developers.'),
                            startChangePin
                        )
                    } else {
                        showError(qsTr('Error'), qsTr('PIN change failed. Tries left: %1').arg(retries), startChangePin)
                    }
                }
            })
        }
    }

    ChangePinDialog {
        id: changePivPuk
        codeName: 'PUK'

        onCodeChanged: {
            device.piv_change_puk(currentCode, newCode, function(result) {
                var success = result[0];
                var retries = result[1];
                if (success) {
                    showMessage(qsTr('Success'), qsTr('PUK was successfully changed.'))
                } else {
                    if (retries === null) {
                        showError(
                            qsTr('Error'),
                            qsTr('PUK change failed. This is probably a bug, please report it to the developers.'),
                            startChangePuk
                        )
                    } else {
                        showError(qsTr('Error'), qsTr('PUK change failed. Tries left: %1').arg(retries), startChangePuk)
                    }
                }
            })
        }
    }

    DefaultDialog {
        id: changePivManagementKeyDialog

        PivSetManagementKeyForm {
            id: pivSetManagementKeyForm
            device: yk
            onChangeSuccessful: changePivManagementKeyDialog.hide()
        }
    }

    PivResetDialog {
        id: pivResetDialog
        device: yk
    }

    function showError(title, text, callback) {
        errorDialog.callback = callback
        errorDialog.text = text
        errorDialog.title = title
        errorDialog.open()
    }

    function showMessage(title, text) {
        messageDialog.title = title
        messageDialog.text = text
        messageDialog.open()
    }

    MessageDialog {
        id: errorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok

        onAccepted: {
            if (callback) {
                callback()
            }
        }

        property var callback
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

    PivPinPromptDialog {
        id: pinPromptDialog
    }

    PivManagementKeyPromptDialog {
        id: keyPromptDialog
    }

    function askPin(callback, message) {
        pinPromptDialog.ask(callback, message)
    }

    function askManagementKey(callback, message) {
        keyPromptDialog.ask(callback, message)
    }

    function start() {
        show()
    }

    function startChangePin() {
        changePivPin.open()
    }

    function startChangePuk() {
        changePivPuk.open()
    }

    function startChangeManagementKey() {
        changePivManagementKeyDialog.show()
    }

    function startReset() {
        pivResetDialog.open()
    }

}