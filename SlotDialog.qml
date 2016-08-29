import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("Configure YubiKey slots")

    property var device
    property var slotsEnabled: [false, false]
    property bool hasDevice: device ? device.hasDevice : false
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
                    text: statusText(slotsEnabled[0])
                }

                Button {
                    text: qsTr("Configure")
                    onClicked: configureSlot(1)
                }

                Text {
                    text: qsTr("Long press:")
                }

                Text {
                    text: statusText(slotsEnabled[1])
                }

                Button {
                    text: qsTr("Configure")
                    onClicked: configureSlot(2)
                }

                Button {
                    text: qsTr("Swap credentials between slots")
                    Layout.columnSpan: 2
                    onClicked: confirmSwap.open()
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

    function statusText(configured) {
        return configured ? qsTr("Configured") : qsTr("Empty")
    }

    function configureSlot(slot) {
        selectedSlot = slot
        if (slotsEnabled[slot - 1]) {
            loader.sourceComponent = slotStatus
        } else {
            loader.sourceComponent = selectTypeDialog
        }
    }

    function update() {
        device.slots_status(function (res) {
            slotsEnabled = res
        })
    }

    MessageDialog {
        id: confirmSwap
        icon: StandardIcon.Warning
        title: "Swap credentials between slots"
        text: "Do you want to swap the credentials between short press and long press?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            device.swap_slots()
            update()
            close()
        }
        onNo: close()
    }

    Component {
        id: slotStatus
        ColumnLayout {
            Text {
                textFormat: Text.StyledText
                text: "<h2>" + getHeading() + "</h2> <p>The slot is configured.</p>"
            }

            GridLayout {
                columns: 2
                Button {
                    text: "New configuration"
                    onClicked: loader.sourceComponent = selectTypeDialog
                }

                Button {
                    text: "Erase"
                    onClicked: eraseSlot()
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: qsTr("Back")
                    onClicked: loader.sourceComponent = overview
                }
            }
        }
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
            update()
            close()
        }
        onNo: close()
    }

    Component {
        id: selectTypeDialog
        ColumnLayout {
            Text {
                textFormat: Text.StyledText
                text: "<h2>" + qsTr("Configure ") + getHeading() + "</h2> <p>Select the type of functionality to configure:</p>"
            }
            RowLayout {
                ColumnLayout {
                    ExclusiveGroup {
                        id: typeAlternatives
                    }
                    RadioButton {
                        text: qsTr("YubiKey OTP")
                        exclusiveGroup: typeAlternatives
                        checked: true
                        property string name: "otp"
                        property string desc: qsTr("Programs a onte-time-passwordcredential using the YubiKey OTP protocol.")
                    }
                    RadioButton {
                        text: qsTr("Challenge-response")
                        exclusiveGroup: typeAlternatives
                        property string name: "challengeResponse"
                        property string desc: qsTr("Programs a HMAC-SHA1 credential,which can be used for local authentication or encryption.")
                    }
                    RadioButton {
                        text: qsTr("Static password")
                        exclusiveGroup: typeAlternatives
                        property string name: "staticPassword"
                        property string desc: qsTr("Stores a fixed password,which will be output each time you touch the button.")
                    }
                    RadioButton {
                        text: qsTr("OATH-HOTP")
                        exclusiveGroup: typeAlternatives
                        property string name: "oathHotp"
                        property string desc: qsTr("Stores a numeric one-time-password using the OATH-HOTP standard.")
                    }
                }

                Text {
                    text: typeAlternatives.current.desc
                    verticalAlignment: Text.AlignVCenter
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: qsTr("Back")
                    onClicked: loader.sourceComponent = overview
                }
                Button {
                    text: qsTr("Next")
                    onClicked: openProgramCredDialog(
                                   typeAlternatives.current.name)
                }
            }
        }
    }

    function getHeading() {
        if (selectedSlot === 1)
            return "Short press"
        if (selectedSlot === 2)
            return "Long press"
    }

    function openProgramCredDialog(typeName) {
        switch (typeName) {
        case "otp":
            console.log("otp")
            break
        case "challengeResponse":
            console.log("challengeResponse")
            break
        case "staticPassword":
            console.log("staticPassword")
            break
        case "oathHotp":
            console.log("oathHotp")
            break
        }
    }

}
