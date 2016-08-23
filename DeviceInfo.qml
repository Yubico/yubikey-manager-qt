import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {
    property var device
    anchors.fill: parent

    GroupBox {
        title: qsTr("Device")
        Layout.fillWidth: true

        GridLayout {
            anchors.fill: parent
            columns: 2

            Label {
                id: deviceName
                text: device.name + ' (' + device.version + ')'
            }

            Label {
                text: device.serial ? qsTr("Serial: ") + device.serial : ''
            }
        }
    }

    GroupBox {
        title: qsTr("Features")
        Layout.fillWidth: true

        GridLayout {
            anchors.fill: parent
            flow: GridLayout.TopToBottom
            rows: device.features.length

            Repeater {
                model: device.features

                Label {
                    text: modelData + ':'
                }
            }

            Repeater {
                model: device.features
                Label {
                    text: device.enabled.indexOf(
                              modelData) >= 0 ? qsTr("Enabled") : qsTr(
                                                    "Disabled")
                }
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Configure")
                enabled: device.enabled.indexOf('OTP') >= 0
                onClicked: configureOTPDialog.init()
            }
        }
    }

    GroupBox {
        title: qsTr("Connections")
        Layout.fillWidth: true

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
                onClicked: connectionsDialog.show()
            }
        }
    }

    ConfigureOTPDialog {
        id: configureOTPDialog
        device: yk
    }

    ConnectionsDialog {
        id: connectionsDialog
        device: yk
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
