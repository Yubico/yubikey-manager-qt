import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {
    property var device
    property int margin: Layout.minimumWidth / 30

    Layout.minimumWidth: 370
    Layout.minimumHeight: 360
    height: deviceBox.implicitHeight + featureBox.implicitHeight + connectionsBox.implicitHeight + margin * 4

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
                    visible: device.serial
                    text: qsTr("Serial: ") + device.serial
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

                property var features: [
                    { id: 'OTP', label: qsTr('YubiKey Slots') },
                    { id: 'PIV', label: qsTr('PIV') },
                    { id: 'OATH', label: qsTr('OATH') },
                    { id: 'OPGP', label: qsTr('OpenPGP') },
                    { id: 'U2F', label: qsTr('U2F') },
                ]

                Repeater {
                    model: parent.features
                    Label { text: modelData.label + ':' }
                }
                Repeater {
                    model: parent.features
                    Label {
                        text: (isCapable(modelData.id)
                            ? isEnabled(modelData.id)
                                ? qsTr("Enabled")
                                : qsTr("Disabled")
                            : qsTr("Not available")
                        )
                    }
                }

                Button {
                    Layout.column: 2
                    Layout.row: parent.features.findIndex(function(f) { return f.id === 'OTP'; })
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("Configure")
                    enabled: device.enabled.indexOf('OTP') >= 0
                    onClicked: slotDialog.start()
                }

                Button {
                    Layout.column: 2
                    Layout.row: parent.features.findIndex(function(f) { return f.id === 'PIV'; })
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("Configure")
                    enabled: device.enabled.indexOf('PIV') >= 0
                    onClicked: pivDialog.start()
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
                    text: qsTr("Configure")
                    enabled: device.connections.length > 1
                    onClicked: connectionsDialog.show()
                }
            }
        }

        ConnectionsDialog {
            id: connectionsDialog
            device: yk
        }

        SlotDialog {
            id: slotDialog
            device: yk
        }

        PivManager {
            id: pivDialog
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
