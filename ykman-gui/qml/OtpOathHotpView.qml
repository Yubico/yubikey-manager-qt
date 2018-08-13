import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

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
            text: qsTr("OATH-HOTP")
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            font.pointSize: constants.h1
            color: yubicoBlue
        }

        RowLayout {
            Label {
                text: qsTr("Home")
                color: yubicoGreen
            }

            BreadCrumbSeparator {
            }
            Label {
                text: qsTr("OTP")
                color: yubicoGreen
            }
            BreadCrumbSeparator {
            }

            Label {
                text: SlotUtils.slotNameCapitalized(views.selectedSlot)
                color: yubicoGreen
            }
            BreadCrumbSeparator {
            }

            Label {
                text: qsTr("Select Credential Type")
                color: yubicoGreen
            }

            BreadCrumbSeparator {
            }
            Label {
                text: qsTr("OATH-HOTP")
                color: yubicoGrey
            }
        }

        Label {
            text: qsTr("Secret key")
            font.pointSize: constants.h3
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
                font.pointSize: constants.h3
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
