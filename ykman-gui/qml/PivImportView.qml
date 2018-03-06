import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ColumnLayout {

    property string slotName: ''

    readonly property string hasSlotName: !!slotName

    signal closed
    signal importCertificateAccepted(string certificateFileUrl)
    signal importKeyAccepted(string keyFileUrl, string pinPolicy, string touchPolicy)

    Button {
        text: qsTr('Import certificate')
        onClicked: {
            certifcateFileDialog.open()
        }
    }

    RowLayout {
        ColumnLayout {
            Label {
                text: qsTr('PIN policy')
                font.bold: true
            }

            DropdownMenu {
                id: pinPolicyChoice
                Layout.fillWidth: true
                values: [{
                    text: qsTr('Default for this slot'),
                    value: null,
                }, {
                    text: qsTr('Never'),
                    value: 'NEVER',
                }, {
                    text: qsTr('Once'),
                    value: 'ONCE',
                }, {
                    text: qsTr('Always'),
                    value: 'ALWAYS',
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
                    value: null,
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

    Button {
        text: qsTr('Import private key')
        onClicked: {
            keyFileDialog.open()
        }
    }

    FileDialog {
        id: certifcateFileDialog

        defaultSuffix: 'pem'
        nameFilters: [ 'Certificate files (*.pem)', 'All files (*)']
        selectExisting: true
        title: 'Select file to import'

        onAccepted: importCertificateAccepted(fileUrls[0])
    }

    FileDialog {
        id: keyFileDialog

        defaultSuffix: 'pem'
        nameFilters: [ 'Private key files (*.pem)', 'All files (*)']
        selectExisting: true
        title: 'Select file to import'

        onAccepted: importKeyAccepted(fileUrls[0], pinPolicyChoice.value, touchPolicyChoice.value)
    }

    Button {
        text: 'Cancel'
        onClicked: closed()
    }

    Shortcut {
      sequence: 'Esc'
      onActivated: closed()
    }
}
