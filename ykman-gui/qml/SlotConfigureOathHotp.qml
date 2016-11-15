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
        text: qsTr("Configure HOTP credential for ") + SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Text {
        text: qsTr("When triggered, the YubiKey will output a HOTP code.")
    }
    GroupBox {
        title: qsTr("Secret key")
        Layout.fillWidth: true
        ColumnLayout {
            RowLayout {
                TextField {
                    id: secretKeyInput
                    implicitWidth: 240
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[ 2-7a-zA-Z]+=*/
                    }
                }
            }
            RowLayout {
                Text {
                    text: qsTr("The Secret key should be encoded in base32.")
                }
            }

            RowLayout {
                Text {
                    text: qsTr("Digits")
                }
                ComboBox {
                    model: [ 6, 8 ]
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
            enabled: secretKeyInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onAccepted: programOathHotp()
    }

    MessageDialog {
        id: paddingError
        icon: StandardIcon.Critical
        title: qsTr("Wrong padding")
        text: qsTr("The padding of the key is incorrect.")
        standardButtons: StandardButton.Ok
    }


    function finish() {
        if (slotsEnabled[selectedSlot - 1]) {
            warning.open()
        } else {
            programOathHotp()
        }
    }

    function programOathHotp() {
        device.program_oath_hotp(selectedSlot, secretKeyInput.text,
                                          8,
                                          function (error) {
                                              if (!error) {
                                                  updateStatus()
                                                  confirmConfigured.open()
                                              } else {
                                                  if (error === 'Incorrect padding') {
                                                    paddingError.open()
                                                  }
                                                  if (error === 3) {
                                                    writeError.open()
                                                  }
                                              }
                                          })
    }

}
