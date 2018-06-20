import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import "utils.js" as Utils

ColumnLayout {
    id: deviceInfo
    property var device
    Layout.minimumWidth: app.minimumWidth
    Keys.onTabPressed: btnRepeater.itemAt(0).forceActiveFocus()
    Keys.onEscapePressed: deviceInfo.forceActiveFocus()
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
                    visible: device.serial
                    text: qsTr("Serial: ") + device.serial
                }
            }
        }

        GroupBox {
            id: featureBox
            title: qsTr("Applications")
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridLayout {
                flow: GridLayout.TopToBottom
                rows: features.length
                anchors.right: parent.right
                anchors.left: parent.left
                property var features: [{
                        id: 'OTP',
                        label: qsTr('OTP'),
                        onConfigure: slotDialog.load
                    }, {
                        id: 'FIDO2',
                        label: qsTr('FIDO2'),
                        onConfigure: fidoDialog.load
                    }, {
                        id: 'U2F',
                        label: qsTr('FIDO U2F')
                    }, {
                        id: 'PIV',
                        label: qsTr('PIV')
                    }, {
                        id: 'OATH',
                        label: qsTr('OATH')
                    }, {
                        id: 'OPGP',
                        label: qsTr('OpenPGP')
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
                        text: (isApplicationSupported(
                                   modelData.id) ? isApplicationEnabled(
                                                       modelData.id) ? qsTr("Enabled") : qsTr(
                                                                           "Disabled") : qsTr(
                                                                           "Not available"))
                    }
                }

                Repeater {
                    id: btnRepeater
                    model: parent.features
                    Button {
                        Layout.column: 2
                        Layout.row: index
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Configure...")
                        enabled: isApplicationEnabled(modelData.id)
                        visible: parent.features[index].onConfigure !== undefined
                        focus: true
                        Keys.onTabPressed: {
                            var nextButton = btnRepeater.itemAt(index + 1)
                            if (nextButton.enabled && nextButton.visible) {
                                nextButton.forceActiveFocus()
                            } else {
                                connectionsBtn.forceActiveFocus()
                            }
                        }
                        onClicked: parent.features[index].onConfigure()
                    }
                }
            }
        }

        GroupBox {
            id: connectionsBox
            title: qsTr("USB Interfaces")
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
                    text: readable_list(device.supportedUsbInterfaces)
                    Layout.columnSpan: 2
                }

                Label {
                    text: qsTr("Enabled:")
                }

                Label {
                    text: readable_list(device.enabledUsbInterfaces)
                }
                Button {
                    id: connectionsBtn
                    text: qsTr("Configure...")
                    Layout.alignment: Qt.AlignRight
                    enabled: device.supportedUsbInterfaces.length > 1
                    onClicked: connectionsDialog.load()
                }
            }
        }
    }
    function isApplicationEnabled(feature) {
        return Utils.includes(device.enabledUsbApplications, feature)
    }

    function isApplicationSupported(feature) {
        return Utils.includes(device.supportedUsbApplications, feature)
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
