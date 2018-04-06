import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

ColumnLayout {
    Keys.onTabPressed: deleteSlot1Btn.forceActiveFocus()
    Keys.onEscapePressed: close()
    GroupBox {
        Layout.fillWidth: true
        title: qsTr("Short Touch (Slot 1)")
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: qsTr("The Short Touch slot is currently ")
                      + (slotsConfigured[0] ? qsTr("configured.") : qsTr(
                                                  "empty."))
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Button {
                    id: deleteSlot1Btn
                    text: qsTr("Delete...")
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    KeyNavigation.tab: configureSlot1Btn
                    enabled: slotsConfigured[0]
                    onClicked: {
                        selectedSlot = 1
                        deleteSlotDialog.open()
                    }
                }
                Button {
                    id: configureSlot1Btn
                    text: qsTr("Configure...")
                    KeyNavigation.tab: deleteSlot2Btn
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                    onClicked: {
                        selectedSlot = 1
                        stack.push({
                                       item: slotSelectType,
                                       immediate: true
                                   })
                    }
                }
            }
        }
    }
    GroupBox {
        Layout.fillWidth: true
        title: qsTr("Long Touch (Slot 2)")
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: qsTr("The Long Touch slot is currently ")
                      + (slotsConfigured[1] ? qsTr("configured.") : qsTr(
                                                  "empty."))
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Button {
                    id: deleteSlot2Btn
                    enabled: slotsConfigured[1]
                    text: qsTr("Delete...")
                    KeyNavigation.tab: configureSlot2Btn
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    onClicked: {
                        selectedSlot = 2
                        deleteSlotDialog.open()
                    }
                }
                Button {
                    id: configureSlot2Btn
                    text: qsTr("Configure...")
                    KeyNavigation.tab: swapBtn
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    onClicked: {
                        selectedSlot = 2
                        stack.push({
                                       item: slotSelectType,
                                       immediate: true
                                   })
                    }
                }
            }
        }
    }
    GroupBox {
        Layout.fillWidth: true
        title: qsTr("Swap slots")
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            anchors.fill: parent
            Label {
                text: qsTr("Swap configuration between slots.")
            }
            Button {
                id: swapBtn
                KeyNavigation.tab: cancelBtn
                text: qsTr("Swap...")
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                enabled: slotsConfigured[0] || slotsConfigured[1]
                onClicked: swapSlotsDialog.open()
            }
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        Button {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            id: cancelBtn
            KeyNavigation.tab: deleteSlot1Btn
            text: qsTr("Cancel")
            onClicked: close()
        }
    }
}
