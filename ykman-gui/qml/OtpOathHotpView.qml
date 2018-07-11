import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

    function heading() {
        return qsTr("Configure ") + SlotUtils.slotNameCapitalized(
                    views.selectedSlot)
    }
    function finish() {
        if (views.selectedSlotConfigured()) {
            otpSlotAlreadyConfigured.open()
        } else {
            programOathHotp()
        }
    }

    function programOathHotp() {
        yubiKey.program_oath_hotp(views.selectedSlot, secretKeyInput.text,
                                  digits.currentText, function (resp) {
                                      if (resp.success) {
                                          views.otpSuccess()
                                      } else {
                                          if (resp.error === 'write error') {
                                              views.otpWriteError()
                                          } else {
                                              views.otpGeneralError(resp.error)
                                          }
                                      }
                                  })
    }

    OtpSlotAlreadyConfigured {
        id: otpSlotAlreadyConfigured
        onAccepted: programOathHotp()
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
        TextField {
            id: secretKeyInput
            Layout.fillWidth: true
            validator: RegExpValidator {
                regExp: /[ 2-7a-zA-Z]+=*/
            }
        }
        RowLayout {
            Label {
                text: qsTr("Digits")
                font.pointSize: 18
                color: yubicoBlue
            }
            ComboBox {
                id: digits
                model: [6, 8]
            }
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
                id: nextBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: secretKeyInput.acceptableInput
            }
        }
    }
}
