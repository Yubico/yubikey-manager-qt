import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Dialog {
    property var device

    title: qsTr("Configure connections")
    //standardButtons: StandardButton.Ok | StandardButton.Cancel

    onAccepted: function() {
        var enabled = get_enabled()
        device.set_mode(enabled, function(e) {
            if(e) {
                console.log('Error setting mode: ' + e)
            } else {
                console.log('Mode set: "' + enabled + '", eject now.')
                ejectNow.show()
            }
        })
    }

    ColumnLayout {
        anchors.fill: parent

        Text {
            textFormat: Text.StyledText
            text: qsTr("<h2>Configure enabled connection protocols</h2>
<p>Set the enabled connection protocols for your YubiKey.</p>
<p>Once changed, you will need to unplug and re-insert your YubiKey for the settings to take effect.</p>")
        }

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                id: connections
                model: device.connections

                CheckBox {
                    Layout.fillWidth: true
                    text: modelData
                    checked: device.enabled.indexOf(modelData) >= 0
                    onCheckedChanged: button_ok.enabled = check_acceptable()
                }
            }
        }
    }

    /*Message*/Dialog {
        id: ejectNow
        title: qsTr('Connections configured')
        //text: qsTr('Please remove, then re-insert your YubiKey.')
        //standardButtons: StandardButton.OK & 0
    }

    QtObject {
        readonly property bool hasDevice: device.hasDevice
        onHasDeviceChanged: if(!hasDevice) ejectNow.close()
    }

    function get_enabled() {
        var enabled = []
        for(var i=0; i<device.connections.length; i++) {
            var connection_checkbox = connections.itemAt(i)
            if(connection_checkbox.checked) {
                enabled.push(connection_checkbox.text)
            }
        }
        return enabled
    }

    function check_acceptable() {
        for(var i=0; i<device.connections.length; i++) {
            if(connections.itemAt(i).checked) {
                return true
            }
        }
        return false
    }
}
