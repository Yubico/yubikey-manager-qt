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
    property string generateKeySlotName: ''

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
                        pinCallback: function(callback, message) {
                            pinPromptDialog.ask(callback, message)
                        },
                        keyCallback: function(callback, message) {
                            keyPromptDialog.ask(callback, message)
                        },
                        touchCallback: function() {
                            touchYubiKeyPrompt.show()
                        }
                    })
                }

                onExportCertificate: {
                    exportFileDialog.slotName = slotName
                    exportFileDialog.open()
                }

                onGenerateKey: {
                    generateKeySlotName = slotName
                    push(generateKeyView)
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
            slotName: generateKeySlotName
            onAccepted: {
                device.piv_generate_certificate({
                    slotName: slotName,
                    algorithm: algorithm,
                    csrFileUrl: csrFileUrl,
                    expirationDate: expirationDate,
                    selfSign: selfSign,
                    subjectDn: subjectDn,
                    touchPolicy: touchPolicy,
                    callback: function(result) {
                        if (result.success) {
                            pop()
                        } else {
                            showError('Generate failed', 'Failed to generate certificate: ' + (result.message || 'unknown error.'))
                        }
                    },
                    pinCallback: function(callback, message) {
                        pinPromptDialog.ask(callback, message)
                    },
                    keyCallback: function(callback, message) {
                        keyPromptDialog.ask(callback, message)
                    },
                    touchCallback: function() {
                        touchYubiKeyPrompt.show()
                    },
                })
            }
            onClosed: pop()
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
        message: 'Please enter the PIV PIN.'
        title: 'PIV PIN required'
    }

    PivPinPromptDialog {
        id: keyPromptDialog
        hideInput: false
        message: 'Please enter the PIV management key.'
        title: 'PIV management key required'
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
