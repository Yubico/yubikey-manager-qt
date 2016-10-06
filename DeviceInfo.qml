import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {
    property var device
    property int margin: width / 30

    width: 370
    height: deviceBox.height + featureBox.height + connectionsBox.height + margin * 4

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
            id: featureBox
            anchors.top: deviceBox.bottom
            anchors.topMargin: margin
            title: qsTr("Features")
            Layout.fillWidth: true

            GridLayout {
                anchors.fill: parent
                flow: GridLayout.TopToBottom
                rows: device.getSortedFeatures().length

                Repeater {
                    model: device.getSortedFeatures()

                    Label {
                        text: (modelData === 'OPGP') ? 'OpenPGP' + ':' : modelData + ':'
                    }
                }

                Repeater {
                    model: device.getSortedFeatures()
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
                    onClicked: slotDialog.start()
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
