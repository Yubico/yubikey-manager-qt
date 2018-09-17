import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

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
                                              views.otpFailedToConfigureErrorPopup(
                                                          resp.error)
                                          }
                                      }
                                  })
    }

    OtpSlotAlreadyConfiguredPopup {
        id: otpSlotAlreadyConfigured
        onAccepted: programOathHotp()
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: constants.contentMargins
        Layout.topMargin: constants.contentTopMargin
        Layout.bottomMargin: constants.contentBottomMargin
        Layout.preferredHeight: constants.contentHeight
        Layout.maximumHeight: constants.contentHeight
        Layout.preferredWidth: constants.contentWidth
        Layout.maximumWidth: constants.contentWidth
        spacing: 20
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
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
                    text: qsTr(SlotUtils.slotNameCapitalized(
                                   views.selectedSlot))
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
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
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
                ToolTip.text: qsTr("Secret key must be a base32 encoded value")
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
                ToolTip.text: qsTr("Number of digits in generated code")
                Material.foreground: yubicoBlue
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            CustomButton {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
                iconSource: "../images/back.svg"
            }
            CustomButton {
                id: nextBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: secretKeyInput.acceptableInput
                toolTipText: qsTr("Finish and write the configuration to the YubiKey")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
