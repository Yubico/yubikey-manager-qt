import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import "utils.js" as Utils

DefaultDialog {

    property var device
    title: qsTr("Configure USB Interfaces")
    minimumWidth: 500
    onAccepted: changeConnections()

    function load() {
        updateCheckBoxValues()
        show()
    }

    function updateCheckBoxValues() {
        for (var i = 0; i < checkBoxes.model.length; i++) {
            checkBoxes.itemAt(i).checked = Utils.includes(
                        device.enabledUsbInterfaces, checkBoxes.model[i])
        }
    }

    function changeConnections() {
        device.set_mode(getEnabledInterfaces(), function (error) {
            if (error) {
                modeSwitchError.open()
            } else {
                close()
                if (!device.canWriteConfig) {
                    ejectNow.open()
                }
            }
        })
    }

    function getEnabledInterfaces() {
        var enabled = []
        for (var i = 0; i < device.supportedUsbInterfaces.length; i++) {
            if (checkBoxes.itemAt(i).checked) {
                enabled.push(checkBoxes.itemAt(i).text)
            }
        }
        return enabled
    }

    function isAnyInterfaceSelected() {
        for (var i = 0; i < checkBoxes.count; i++) {
            var item = checkBoxes.itemAt(i)
            if (item) {
                if (item.checked) {
                    return true
                }
            }
        }
        return false
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: "Configure enabled USB interfaces"
            font.bold: true
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: infoText.implicitHeight

            Label {
                id: infoText
                text: qsTr("Select the USB interfaces you want to enable for your YubiKey.")
                      + (!device.canWriteConfig ? " After saving you need to remove and re-insert your YubiKey for the settings to take effect." : "")
                wrapMode: Text.Wrap
                width: parent.width
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                id: checkBoxes
                model: device.supportedUsbInterfaces
                CheckBox {
                    Layout.fillWidth: true
                    text: modelData
                    checked: Utils.includes(device.enabledUsbInterfaces,
                                            modelData)
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    close()
                    rejected()
                }
            }
            Button {
                enabled: isAnyInterfaceSelected()
                text: qsTr("Save")
                onClicked: accepted()
            }
        }
    }

    MessageDialog {
        id: ejectNow
        title: qsTr('USB Interfaces Configured')
        icon: StandardIcon.Information
        text: qsTr('USB interfaces are now configured. Remove and re-insert your YubiKey.')
        standardButtons: StandardButton.NoButton

        readonly property bool hasDevice: device.hasDevice
        onHasDeviceChanged: if (!hasDevice) {
                                ejectNow.close()
                            }
    }

    MessageDialog {
        id: modeSwitchError
        title: qsTr('Error configuring USB interfaces')
        icon: StandardIcon.Critical
        text: qsTr('Failed to configure USB interfaces. Make sure the YubiKey does not have restricted access.')
        standardButtons: StandardButton.Ok
    }
}
