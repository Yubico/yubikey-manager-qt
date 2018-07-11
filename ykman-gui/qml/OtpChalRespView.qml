import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

    function heading() {
        return qsTr("Configurein ") + SlotUtils.slotNameCapitalized(
                    views.selectedSlot)
    }

    function generateKey() {
        yubiKey.random_key(20, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpSlotAlreadyConfigured.open()
        } else {
            programChallengeResponse()
        }
    }

    function programChallengeResponse() {
        yubiKey.program_challenge_response(views.selectedSlot,
                                           secretKeyInput.text,
                                           requireTouchCb.checked,
                                           function (resp) {
                                               if (resp.success) {
                                                   views.otpSuccess()
                                               } else {
                                                   if (resp.error === 'write error') {
                                                       views.otpWriteError()
                                                   } else {
                                                       views.otpGeneralError(
                                                                   resp.error)
                                                   }
                                               }
                                           })
    }

    OtpSlotAlreadyConfigured {
        id: otpSlotAlreadyConfigured
        onAccepted: programChallengeResponse()
    }

    ColumnLayout {
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Label {
            text: heading()
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            font.pointSize: 36
            color: yubicoBlue
        }
        Label {
            text: qsTr("Secret key")
            font.pointSize: 18
            color: yubicoBlue
        }
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: secretKeyInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /([0-9a-fA-F]{2}){1,20}$/
                }
            }
            Button {
                id: generateBtn
                text: qsTr("Generate")
                Layout.fillWidth: false
                onClicked: generateKey()
            }
        }
        CheckBox {
            id: requireTouchCb
            enabled: yubiKey.serial
            text: qsTr("Require touch")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
            }
            Button {
                id: finnishBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: secretKeyInput.acceptableInput
            }
        }
    }
}
