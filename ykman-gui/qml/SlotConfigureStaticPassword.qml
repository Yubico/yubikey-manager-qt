import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {

    property var device
    property var slotsEnabled: [false, false]
    property int selectedSlot
    signal configureSlot(int slot)
    signal updateStatus
    signal goToOverview
    signal goToSelectType
    signal goToSlotStatus
    signal goToConfigureOTP
    signal goToChallengeResponse
    signal goToStaticPassword
    signal goToOathHotp

    Text {
        text: qsTr("Configure static password for ") + SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Text {
        textFormat: Text.StyledText
        text: qsTr("When triggered, the YubiKey will output a fixed password.")
    }
    GroupBox {
        title: "Password"
        Layout.fillWidth: true
        ColumnLayout {
            RowLayout {
                TextField {
                    id: passwordInput
                    implicitWidth: 280
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[cbdefghijklnrtuv]{1,38}$/
                    }
                }
                Button {
                    anchors.margins: 5
                    text: qsTr("Generate")
                    anchors.left: passwordInput.right
                    onClicked: generatePassword()
                }
            }
            Item {
                width: minimumWidth - margins * 2
                implicitHeight: desc.implicitHeight
                Text {
                    id: desc
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: qsTr("To avoid problems with different keyboard layouts, only the following characters are allowed: cbdefghijklnrtuv")
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: goToSelectType()
        }
        Button {
            text: qsTr("Finish")
            enabled: passwordInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onAccepted: programStaticPassword()
    }

    function finish() {
        if (slotsEnabled[selectedSlot - 1]) {
            warning.open()
        } else {
            programStaticPassword()
        }
    }

    function generatePassword() {
        device.random_modhex(16, function (res) {
            passwordInput.text = res
        })
    }

    function programStaticPassword() {
        device.program_static_password(selectedSlot, passwordInput.text,
                                       function (error) {
                                           if (!error) {
                                               updateStatus()
                                               confirmConfigured.open()
                                           } else {
                                               if (error === 3) {
                                                 writeError.open()
                                               }
                                           }
                                       })
    }

}
