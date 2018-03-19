import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {
    property bool isSupported

    readonly property var value: enabled ? choice.value : null

    enabled: isSupported

    Label {
        text: qsTr('PIN policy')
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
                value: null
            }, {
                text: qsTr('Never'),
                value: 'NEVER'
            }, {
                text: qsTr('Once'),
                value: 'ONCE'
            }, {
                text: qsTr('Always'),
                value: 'ALWAYS'
            }]
        visible: enabled
    }
}
