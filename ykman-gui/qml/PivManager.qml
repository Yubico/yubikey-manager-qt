import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("PIV Manager")

    property var device
    property bool hasDevice: device ? device.hasDevice : false
    minimumWidth: 500

    ColumnLayout {

        Label {
            text: (hasDevice
                ? qsTr("YubiKey present with applet version: %1").arg(device && device.piv && device.piv.version || '?')
                : qsTr("No YubiKey detected.")
            )
        }

        Button {
            text: qsTr("Change PIN")
            onClicked: changePin.open()
        }

    }

    ChangePinDialog {
        id: changePin
        codeName: 'PIN'

        onCodeChanged: {
            console.log('Change PIN', 'from', currentCode, 'to', newCode)
        }
    }

    function start() {
        show()
    }

}
