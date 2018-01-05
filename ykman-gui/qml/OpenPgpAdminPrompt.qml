import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("Admin PIN for OpenPGP")
    id: opgpSettingsDialog
    minimumWidth: 250
    modality: Qt.ApplicationModal

    property string adminPIN: adminPIN.text
    property alias message: openPgpWrongPin.text

    onVisibilityChanged: {
        // Clear the password from old canceled entries
        // when a new dialog is shown.
        if (visible) {
            clear()
        }
    }

    ColumnLayout {
        RowLayout {
            Label {
                text: qsTr("Admin PIN: ")
            }
            TextField {
                id: adminPIN
                echoMode: TextInput.Password
                focus: true
                Layout.fillWidth: true
                onAccepted: promptAccepted()
                Keys.onEscapePressed: close()
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Button {
                text: qsTr("Cancel")
                id: cancelBtn
                onClicked: close()
                KeyNavigation.tab: adminPIN
                Keys.onEscapePressed: close()
            }
            Button {
                id: okBtn
                text: qsTr("Ok")
                enabled: adminPIN.text.length >= 8
                isDefault: true
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                onClicked: promptAccepted()
                KeyNavigation.tab: cancelBtn
                Keys.onEscapePressed: close()
            }
        }
    }

    MessageDialog {
        id: openPgpWrongPin
        icon: StandardIcon.Critical
        title: qsTr("Wrong Pin!")
        standardButtons: StandardButton.Ok
    }

    function wrongPin(message) {
        openPgpWrongPin.text = message
        openPgpWrongPin.open()
    }

    function promptAccepted() {
        close()
        accepted()
    }

    function clear() {
        adminPIN.text = ''
    }
}
