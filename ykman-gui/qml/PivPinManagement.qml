import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

ColumnLayout {

    property var pinTries

    signal changeManagementKey
    signal changePin
    signal changePuk
    signal closed

    Label {
        text: pinTries != null ? qsTr('PIN tries left: %1').arg(pinTries) : qsTr('PIN tries left: unknown')
    }

    Button {
        text: qsTr("Change PIN")
        onClicked: changePin()
    }

    Button {
        text: qsTr("Change PUK")
        onClicked: changePuk()
    }

    Button {
        text: qsTr("Change Management Key")
        onClicked: changeManagementKey()
    }

    Button {
        text: qsTr("Back")
        onClicked: closed()
    }

    Shortcut {
      sequence: 'Esc'
      onActivated: closed()
    }

}
