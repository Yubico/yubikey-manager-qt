import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

ColumnLayout {

    property string slotName: ''
    property var supportedTouchPolicies
    property bool supportsPinPolicies

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
        PivPinPolicyInput {
            id: pinPolicyChoice
            isSupported: supportsPinPolicies
        }

        PivTouchPolicyInput {
            id: touchPolicyChoice
            supportedPolicies: supportedTouchPolicies
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

        nameFilters: [qsTr('Certificate files (*.pem)'), qsTr('All files (*)')]
        selectExisting: true
        title: qsTr('Select file to import')

        onAccepted: importCertificateAccepted(fileUrls[0])
    }

    FileDialog {
        id: keyFileDialog

        nameFilters: [qsTr('Private key files (*.pem)'), qsTr('All files (*)')]
        selectExisting: true
        title: qsTr('Select file to import')

        onAccepted: importKeyAccepted(fileUrls[0], pinPolicyChoice.value,
                                      touchPolicyChoice.value)
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
