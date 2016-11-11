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
    signal confirmed

    Text {
        text: "Configure challenge-response for " + SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Text {
        text: "When queried, the YubiKey will respond to a challenge."
    }

    RowLayout {
        Text {
            text: qsTr("Secret key")
        }
        TextField {
            id: secretKeyInput
            implicitWidth: 310
            font.family: "Courier"
            validator: RegExpValidator {
                regExp: /[0-9a-fA-F]{40}$/
            }
        }

        Button {
            anchors.margins: 5
            text: qsTr("Generate")
            anchors.left: secretKeyInput.right
            onClicked: generateKey()
        }
    }

    CheckBox {
        id: requireTouch
        text: qsTr("Require touch")
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
        onAccepted: programChallengeResponse()
    }

    function generateKey() {
        device.random_key(20, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (slotsEnabled[selectedSlot - 1]) {
            warning.open()
        } else {
            programChallengeResponse()
        }
    }

    function programChallengeResponse() {
        device.program_challenge_response(selectedSlot, secretKeyInput.text,
                                          requireTouch.checked,
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
