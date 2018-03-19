import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {
    id: deviceInfo
    property var device

    ColumnLayout {
        Layout.margins: 12
        GroupBox {
            id: deviceBox
            title: qsTr("Device")
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridLayout {
                columns: 1
                Label {
                    text: device.name
                }
                Label {
                    text: qsTr("Firmware: ") + device.version
                }
                Label {
                    text: qsTr("Serial: ") + (device.serial ? device.serial : 'Unknown')
                }
            }
        }

        GroupBox {
            id: featureBox
            title: qsTr("Features")
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridLayout {
                flow: GridLayout.TopToBottom
                rows: features.length
                anchors.right: parent.right
                anchors.left: parent.left
                property var features: [{
                        id: 'OTP',
                        label: qsTr('YubiKey Slots'),
                        onConfigure: slotDialog.load
                    }, {
                        id: 'FIDO2',
                        label: qsTr('FIDO 2'),
                        onConfigure: fidoDialog.load
                    }, {
                        id: 'PIV',
                        label: qsTr('PIV'),
                        onConfigure: featureFlag_pivManager ? pivManager.start : undefined
                    }, {
                        id: 'OATH',
                        label: qsTr('OATH')
                    }, {
                        id: 'OPGP',
                        label: qsTr('OpenPGP')
                    }, {
                        id: 'U2F',
                        label: qsTr('U2F')
                    }, {
                        id: 'PIV',
                        label: qsTr('PIV')
                    }]

                Repeater {
                    model: parent.features
                    Label {
                        Layout.column: 0
                        Layout.row: index
                        text: modelData.label + ':'
                    }
                }

                Repeater {
                    model: parent.features
                    Label {
                        Layout.column: 1
                        Layout.row: index
                        text: (isCapable(
                                   modelData.id) ? isEnabled(
                                                       modelData.id) ? qsTr("Enabled") : qsTr(
                                                                           "Disabled") : qsTr(
                                                                           "Not available"))
                    }
                }

                Repeater {
                    model: parent.features
                    Button {
                        Layout.column: 2
                        Layout.row: index
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Configure...")
                        enabled: isEnabled(modelData.id)
                        visible: parent.features[index].onConfigure !== undefined
                        onClicked: parent.features[index].onConfigure()
                    }
                }
            }
        }

        GroupBox {
            id: connectionsBox
            title: qsTr("Connections")
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridLayout {
                anchors.right: parent.right
                anchors.left: parent.left
                columns: 3
                Label {
                    text: qsTr("Supported:")
                }

                Label {
                    text: readable_list(device.connections)
                    Layout.columnSpan: 2
                }

                Label {
                    text: qsTr("Enabled:")
                }

                Label {
                    text: readable_list(device.enabled.filter(function (e) {
                        return device.connections.indexOf(e) >= 0
                    }))
                }
                Button {
                    text: qsTr("Configure...")
                    Layout.alignment: Qt.AlignRight
                    enabled: device.connections.length > 1
                    onClicked: connectionsDialog.show()
                }
            }
        }
    }
    function isEnabled(feature) {
        return device.enabled.indexOf(feature) !== -1
    }

    function isCapable(feature) {
        return device.capabilities.indexOf(feature) !== -1
    }

    function readable_list(args) {
        if (args.length === 0) {
            return ''
        } else if (args.length === 1) {
            return args[0]
        } else {
            args = args.slice() //Don't modify the original array.
            var last = args.pop()
            return args.join(', ') + qsTr(' and ') + last
        }
    }
}
