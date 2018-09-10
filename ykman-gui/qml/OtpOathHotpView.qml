import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.3

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
                                              views.otpFailedToConfigureErrorPopup(resp.error)
                                          }
                                      }
                                  })
    }

    OtpSlotAlreadyConfiguredPopup {
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
        RowLayout {
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
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Secret key must be a base32 encoded value.")
                selectByMouse: true
                selectionColor: yubicoGreen
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
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Number of digits in generated code.")
                Material.foreground: yubicoBlue
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
                icon.source: "../images/back.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
            Button {
                id: nextBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: secretKeyInput.acceptableInput
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and write the configuration to the YubiKey.")
                icon.source: "../images/finish.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
            }
        }
    }
}
