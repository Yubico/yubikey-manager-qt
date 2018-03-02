import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ColumnLayout {

    property string slotName: ''

    readonly property string hasSlotName: !!slotName

    signal closed
    signal importCertificateAccepted(string certificateFileUrl)

    Button {
        text: qsTr('Import certificate')
        onClicked: {
            certifcateFileDialog.open()
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

    Shortcut {
      sequence: 'Esc'
      onActivated: closed()
    }
}
