import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("Configure YubiKey slots")

    property var device
    property bool hasDevice: device ? device.hasDevice : false
    property bool slot1enabled
    property bool slot2enabled
    property int selectedSlot

    onHasDeviceChanged: close()

    Loader {
        id: loader
        sourceComponent: overview
    }

    Component {
        id: overview
        ColumnLayout {
            id: container

            Text {
                textFormat: Text.StyledText
                text: qsTr("<h2>Configure YubiKey slots</h2>")
            }
            GridLayout {
                columns: 3

                Text {
                    text: qsTr("Short press:")
                }

                Text {
                    text: statusText(slot1enabled)
                }

                Button {
                    text: qsTr("Configure")
                    onClicked: configureSlot(1)
                }

                Text {
                    text: qsTr("Long press:")
                }

                Text {
                    text: statusText(slot2enabled)
                }

                Button {
                    text: qsTr("Configure")
                    onClicked: configureSlot(2)
                }

                Button {
                    text: qsTr("Swap credentials between slots")
                    Layout.columnSpan : 2
                    onClicked: {
                        console.log("Swapping...")
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: qsTr("Close")
                    onClicked: close()
                }
            }
        }

    }

    Component {
        id: slotStatus
        ColumnLayout {
            Text {
                id: heading
                textFormat: Text.StyledText
                text: "<h2>" + getHeading() + "</h2> <p>The slot is configured.</p>"
            }

            GridLayout {
                columns: 2
                Button {
                    text: "New configuration"
                    onClicked: loader.sourceComponent = type
                }

                Button {
                    id: eraseButton
                    text: "Erase"
                    onClicked: eraseSlot()
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: qsTr("Back")
                    onClicked: loader.sourceComponent =  overview
                }
            }
        }
    }

    Component {
        id: type
        ColumnLayout {
            Text {
                textFormat: Text.StyledText
                text: "<h2>" + qsTr("Configure ") + getHeading() + "</h2> <p>Select the type of functionality to configure:</p>"
            }

            RowLayout {
                    ColumnLayout {
                        ExclusiveGroup {
                            id: slotType
                        }
                        RadioButton {
                            text: qsTr("YubiKey OTP")
                            exclusiveGroup: slotType
                            checked: true
                            property string desc: qsTr("Programs a onte-time-passwordcredential using the YubiKey OTP protocol.")
                        }
                        RadioButton {
                            text: qsTr("Challenge-response")
                            exclusiveGroup: slotType
                            property string desc: qsTr("Programs a HMAC-SHA1 credential,which can be used for local authentication or encryption.")
                        }
                        RadioButton {
                            text: qsTr("Static password")
                            exclusiveGroup: slotType
                            property string desc: qsTr("Stores a fixed password,which will be output each time you touch the button.")
                        }
                        RadioButton {
                            text: qsTr("OATH-HOTP")
                            exclusiveGroup: slotType
                            property string desc: qsTr("Stores a numeric one-time-password using the OATH-HOTP standard.")
                        }
                    }

                Text {
                    text: slotType.current.desc
                    verticalAlignment: Text.AlignVCenter
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: qsTr("Back")
                    onClicked: loader.sourceComponent =  overview
                }
                Button {
                    text: qsTr("Next")
                }
            }
        }
    }

    function statusText(configured) {
        return configured ? qsTr("Configured") : qsTr("Empty")
    }

    function getHeading() {
        if (selectedSlot === 1)
            return "Short press"
        if (selectedSlot === 2)
            return "Long press"
    }

    function configureSlot(slot) {
        selectedSlot = slot
        device.slots_status(function (res) {
            var configured = res[slot - 1]
            if (configured) {
                loader.sourceComponent = slotStatus
            } else {
                console.log("Not configured, open configuration wizard.")
            }
        })
    }

    function eraseSlot() {
        confirmErase.slot = selectedSlot
        confirmErase.open()
    }

    MessageDialog {
        property int slot
        id: confirmErase
        icon: StandardIcon.Warning
        title: "Erase YubiKey slot" + slot
        text: "Do you want to erase the content of slot " + slot
              + "? This permanently deletes the contents of this slot."
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.erase_slot(slot)
            close()
        }
        onNo: close()
    }

}
