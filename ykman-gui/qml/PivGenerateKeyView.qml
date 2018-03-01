import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "utils.js" as Utils

ColumnLayout {

    property string slotName: ''

    property var csrFile
    readonly property string hasSlotName: !!slotName
    property alias selfSign: selfSignedChoice.checked

    signal accepted(string algorithm, bool selfSign, var csrFileUrl, string subjectDn, string expirationDate, string touchPolicy)
    signal closed

    Label {
        text: qsTr('A new private key will be generated and stored in the %1 slot.').arg(slotName)
    }

    RowLayout {

        ColumnLayout {
            Label {
                text: qsTr('Algorithm')
                font.bold: true
            }

            DropdownMenu {
                id: algorithmChoice
                Layout.fillWidth: true
                values: [{
                    text: qsTr('ECC (P-256)'),
                    value: 'ECCP256',
                }, {
                    text: qsTr('ECC (P-384)'),
                    value: 'ECCP384',
                }, {
                    text: qsTr('RSA (1024 bits)'),
                    value: 'RSA1024',
                }, {
                    text: qsTr('RSA (2048 bits)'),
                    value: 'RSA2048',
                }]
            }
        }

        ColumnLayout {
            Label {
                text: qsTr('Touch policy')
                font.bold: true
            }

            DropdownMenu {
                id: touchPolicyChoice
                Layout.fillWidth: true
                values: [{
                    text: qsTr('Default for this slot'),
                    value: 'DEFAULT',
                }, {
                    text: qsTr('Never'),
                    value: 'NEVER',
                }, {
                    text: qsTr('Always'),
                    value: 'ALWAYS',
                }, {
                    text: qsTr('Cached'),
                    value: 'CACHED',
                }]
            }
        }

    }

    RowLayout {
        Label {
            text: qsTr('Subject:')
        }
        TextField {
            id: subjectDn
            Layout.fillWidth: true
            placeholderText: 'Alice'
            validator: RegExpValidator {
                regExp: /^.+$/
            }
        }
    }

    RowLayout {
        Label {
            text: qsTr('Expiration date:')
        }
        TextField {
            id: expirationDate
            placeholderText: 'YYYY-MM-DD'
            validator: RegExpValidator {
                regExp: /^\d{4}-\d{2}-\d{2}$/
            }
        }
    }

    Label {
        text: qsTr('Output')
        font.bold: true
    }

    ExclusiveGroup {
        id: outputChoice
    }

    RadioButton {
        id: selfSignedChoice
        text: qsTr('Create a self-signed certificate')
        exclusiveGroup: outputChoice
        checked: true
    }

    RowLayout {

        RadioButton {
            id: csrChoice
            text: qsTr('Certificate Signing Request (CSR)')
            exclusiveGroup: outputChoice
        }

        TextField {
            id: csrFileField
            Layout.fillWidth: true
            enabled: csrChoice.checked
            readOnly: true
            text: csrFile || ''
            placeholderText: qsTr('CSR file...')
        }

        Button {
            enabled: csrChoice.checked
            text: qsTr('Browse...')
            onClicked: csrFileDialog.open()
        }

    }


    RowLayout {
        Button {
            text: qsTr('Cancel')
            onClicked: closed()
        }

        Button {
            enabled: subjectDn.acceptableInput && expirationDate.acceptableInput
            text: qsTr('Ok')
            onClicked: {
                accepted(
                    algorithmChoice.value,
                    selfSign,
                    selfSign ? null : csrFile,
                    subjectDn.text,
                    expirationDate.text,
                    touchPolicyChoice.value
                )
            }
        }
    }

    FileDialog {
        id: csrFileDialog
        title: 'Select CSR destination file'
        selectExisting: false
        defaultSuffix: 'csr'
        nameFilters: [ 'Certificate signing request (*.csr)', 'All files (*)']

        onAccepted: {
            csrFile = fileUrls[0]
        }
    }
}
