import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {
    property var device
    property int margin: Layout.minimumWidth / 30

    Layout.minimumWidth: 370
    Layout.minimumHeight: deviceBox.implicitHeight + featureBox.implicitHeight
                          + connectionsBox.implicitHeight + margin * 4
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: margin
        anchors.rightMargin: margin
        anchors.bottomMargin: margin

        GroupBox {
            id: deviceBox
            title: qsTr("Device")
            Layout.fillWidth: true
            anchors.topMargin: margin
            anchors.top: parent.top
            GridLayout {
                anchors.fill: parent
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
            anchors.top: deviceBox.bottom
            anchors.topMargin: margin
            title: qsTr("Features")
            Layout.fillWidth: true

            GridLayout {
                anchors.fill: parent
                flow: GridLayout.TopToBottom
                rows: features.length

                property var features: [{
                        id: 'OTP',
                        label: qsTr('YubiKey Slots'),
                        onConfigure: slotDialog.load
                    }, {
                        id: 'FIDO2',
                        label: qsTr('FIDO 2')
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
                Button {
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("Configure...")
                    enabled: isEnabled('FIDO2')
                    visible: isEnabled('FIDO2')
                    onClicked: fidoDialog.load()
                }
            }
        }

        GroupBox {
            id: connectionsBox
            title: qsTr("Connections")
            Layout.fillWidth: true
            anchors.top: featureBox.bottom
            anchors.topMargin: margin
            anchors.bottomMargin: margin

            GridLayout {
                anchors.fill: parent
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
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("Configure...")
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
