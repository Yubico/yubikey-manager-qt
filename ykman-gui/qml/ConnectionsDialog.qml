import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

DefaultDialog {

    property var device
    title: qsTr("Configure Connections")
    minimumWidth: 500
    onAccepted: {
        var enabled = get_enabled()
        device.set_mode(enabled, function (error) {
            if (error) {
                if (error === 'Failed to switch mode.') {
                    modeSwitchError.open()
                }
            } else {
                close()
                ejectNow.open()
            }
        })
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: "Configure enabled connection protocols"
            font.bold: true
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: infoText.implicitHeight

            Label {
                id: infoText
                text: qsTr("Select the connections you want to enable for your YubiKey. After saving you need to remove and re-insert your YubiKey for the settings to take effect.")
                wrapMode: Text.Wrap
                width: parent.width
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                id: connections
                model: device.connections

                CheckBox {
                    Layout.fillWidth: true
                    text: modelData
                    checked: device.enabled.indexOf(modelData) >= 0
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
                id: button_confirm
                enabled: check_acceptable()
                text: qsTr("Save connections")
                onClicked: {
                    accepted()
                }
            }
        }
    }

    MessageDialog {
        id: ejectNow
        title: qsTr('Connections configured')
        icon: StandardIcon.Information
        text: qsTr('Connections are now configured. Remove and re-insert your YubiKey.')
        standardButtons: StandardButton.NoButton

        readonly property bool hasDevice: device.hasDevice
        onHasDeviceChanged: if (!hasDevice)
                                ejectNow.close()
    }

    MessageDialog {
        id: modeSwitchError
        title: qsTr('Error configuring connections')
        icon: StandardIcon.Critical
        text: qsTr('Failed to configure connections. Make sure the YubiKey does not have restricted access.')
        standardButtons: StandardButton.Ok
    }

    function get_enabled() {
        var enabled = []
        for (var i = 0; i < device.connections.length; i++) {
            var connection_checkbox = connections.itemAt(i)
            if (connection_checkbox.checked) {
                enabled.push(connection_checkbox.text)
            }
        }
        return enabled
    }

    function check_acceptable() {
        for (var i = 0; i < connections.count; i++) {
            var item = connections.itemAt(i)
            if (item) {
                if (item.checked) {
                    return true
                }
            }
        }
        return false
    }
}
