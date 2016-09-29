import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

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
        textFormat: Text.StyledText
        text: "<h2>Configure HOTP credential</h2><br/><p>When triggered, the YubiKey will output a HOTP code.<p>"
    }

    RowLayout {
        Text {
            text: qsTr("Secret key")
        }
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
            text: qsTr("Digits")
        }
        ComboBox {
            model: [ 6, 8 ]
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
                                                  // TODO: Handle errors, access code case.
                                                  console.log(error)
                                              }
                                          })
    }

}
