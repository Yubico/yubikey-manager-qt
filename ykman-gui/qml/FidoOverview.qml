import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: initialColumn
    Keys.onTabPressed: setPinBtn.forceActiveFocus()
    Keys.onEscapePressed: close()
    GroupBox {
        Layout.fillWidth: true
        title: qsTr("FIDO 2 PIN Management")
        RowLayout {
            anchors.fill: parent
            Label {
                text: pinMessage
            }
            Button {
                id: setPinBtn
                KeyNavigation.tab: resetBtn
                text: hasPin ? qsTr("Change PIN...") : qsTr("Set PIN...")
                enabled: !pinBlocked
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onClicked: stack.push({
                                          item: fidoChangePinDialog,
                                          immediate: true
                                      })
            }
        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: qsTr("Reset FIDO Module")
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: qsTr("• Delete all FIDO U2F Credentials.
• Delete all FIDO 2 Credentials.
• Delete FIDO 2 PIN.")
            }
            Button {
                id: resetBtn
                KeyNavigation.tab: cancelBtn
                text: qsTr("Reset...")
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                onClicked: stack.push({
                                          item: fidoResetDialog,
                                          immediate: true
                                      })
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        Button {
            id: cancelBtn
            KeyNavigation.tab: setPinBtn
            text: qsTr("Cancel")
            onClicked: close()
        }
    }
}
