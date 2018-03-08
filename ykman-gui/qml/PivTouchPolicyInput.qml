import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "utils.js" as Utils


ColumnLayout {
    property var supportedPolicies

    readonly property var value: enabled ? choice.value : null

    enabled: supportedPolicies.length > 0

    Label {
        text: qsTr('Touch policy')
        font.bold: true
    }

    Label {
        text: qsTr('Not supported on this YubiKey.')
        font.italic: true
        visible: !choice.visible
    }

    DropdownMenu {
        id: choice
        Layout.fillWidth: true
        values: [{
                text: qsTr('Default for this slot'),
                value: 'DEFAULT'
            }, {
                text: qsTr('Never'),
                value: 'NEVER'
            }, {
                text: qsTr('Always'),
                value: 'ALWAYS'
            }, {
                text: qsTr('Cached'),
                value: 'CACHED'
            }].filter(function(value) {
                return Utils.includes(supportedPolicies, value.value)
            })
        visible: supportedPolicies.length > 0
    }
}
