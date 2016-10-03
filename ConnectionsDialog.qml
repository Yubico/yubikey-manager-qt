import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {
    property var device

    title: qsTr("Configure connections")
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

        Text {
            textFormat: Text.StyledText
            text: "<h2>Configure enabled connection protocols</h2>"
        }

        Item {
            width: minimumWidth - margins * 2
            implicitHeight: infoText.implicitHeight

            Text {
                id: infoText
                text: qsTr("Set the enabled connection protocols for your YubiKey. Once changed, you will need to unplug and re-insert your YubiKey for the settings to take effect.")
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
                    enabled: modelData !== 'NFC'
                    onCheckedChanged: button_ok.enabled = check_acceptable()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                id: button_ok
                text: qsTr("OK")
                onClicked: {
                    accepted()
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    close()
                    rejected()
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
                if (item.text === 'NFC') {
                    continue
                }
                if (item.checked) {
                    return true
                }
            }
        }
        return false
    }
}
