import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ColumnLayout {

    property string slotName: ''

    property var csrFile
    readonly property string hasSlotName: !!slotName
    property alias selfSign: selfSignedChoice.checked

    signal accepted(string algorithm, bool selfSign, var csrFileUrl, string subjectDn, string expirationDate)
    signal closed

    Label {
        text: qsTr('A new private key will be generated and stored in the %1 slot.').arg(slotName)
    }

    Label {
        text: qsTr('Algorithm')
        font.bold: true
    }

    ExclusiveGroup {
        id: algorithmChoice
    }

    RadioButton {
        text: qsTr('RSA (1024 bits)')
        exclusiveGroup: algorithmChoice
        readonly property string value: 'RSA1024'
    }

    RadioButton {
        text: qsTr('RSA (2048 bits)')
        exclusiveGroup: algorithmChoice
        readonly property string value: 'RSA2048'
    }

    RadioButton {
        text: qsTr('ECC (P-256)')
        exclusiveGroup: algorithmChoice
        checked: true
        readonly property string value: 'ECCP256'
    }

    RadioButton {
        text: qsTr('ECC (P-384)')
        exclusiveGroup: algorithmChoice
        readonly property string value: 'ECCP384'
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
                    algorithmChoice.current.value,
                    selfSign,
                    selfSign ? null : csrFile,
                    subjectDn.text,
                    expirationDate.text
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
