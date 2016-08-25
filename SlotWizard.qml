import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

DefaultDialog {

    property int slot
    property var device
    property bool configured
    signal resetLoader

    onResetLoader: loader.sourceComponent = slotStatus

    title: qsTr("Configure YubiKey slots")

    Loader {
        id: loader
    }

    Component {
        id: slotStatus
        ColumnLayout {
            Text {
                id: heading
                textFormat: Text.StyledText
                text: "<h2>" + getHeading(
                          slot) + "</h2> <p>The slot is configured.</p>"
            }

            GridLayout {
                columns: 2
                Button {
                    text: "New configuration"
                    onClicked: chooseType()
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
                    text: qsTr("Close")
                    onClicked: close()
                }
            }
        }
    }
    Component {
        id: type
        ColumnLayout {
            Text {
                textFormat: Text.StyledText
                text: "<h2>" + qsTr("Configure ") + getHeading(
                          slot) + "</h2> <p>Select the type of functionality to configure:</p>"
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
                    onClicked: close()
                }
                Button {
                    text: qsTr("Next")
                }
            }
        }
    }

    function chooseType() {
        loader.sourceComponent = type
    }

    function eraseSlot() {
        confirmErase.slot = slot
        confirmErase.open()
    }

    function getHeading(slot) {
        if (slot === 1)
            return "Short press"
        if (slot === 2)
            return "Long press"
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
