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

        Heading1 {
            text: qsTr("OATH-HOTP")
        }

        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("OTP")
                action: views.otp
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr(SlotUtils.slotNameCapitalized(views.selectedSlot))
                action: views.otp
            }

            BreadCrumbSeparator {
            }

            BreadCrumb {
                text: qsTr("Select Credential Type")
                action: views.pop
            }

            BreadCrumbSeparator {
            }

            BreadCrumb {
                text: qsTr("OATH-HOTP")
                active: true
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
