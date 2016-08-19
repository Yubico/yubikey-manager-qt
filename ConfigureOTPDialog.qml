import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Dialog {
    property var device

    title: qsTr("Configure YubiKey slots")

    GridLayout{
        columns: 4
        Text {
            text: qsTr("Slot 1 (short press):")
        }

        Text {
            // Status
        }

        Button {
            text: qsTr("Configure")
        }

        Button {
            text: qsTr("Erase")
        }

        Text {
            text: qsTr("Slot 2 (short press):")
        }

        Text {
            // Status
        }

        Button {
            text: qsTr("Configure")
        }

        Button {
            text: qsTr("Erase")
        }
    }
}
