import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string keyboardLayout: allowNonModhex.checked ? 'US' : 'MODHEX'

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpConfirmOverwrite(programStaticPassword)
        } else {
            programStaticPassword()
        }
    }

    function programStaticPassword() {
        yubiKey.programStaticPassword(views.selectedSlot, passwordInput.text,
                                      keyboardLayout, function (resp) {
                                          if (resp.success) {
                                              views.otp()
                                              snackbarSuccess.show(
                                                          "Configured static password")
                                          } else {
                                              if (resp.error_id === 'write error') {
                                                  views.otpWriteError()
                                              } else {
                                                  views.otpFailedToConfigureErrorPopup(
                                                              resp.error_id)
                                              }
                                          }
                                      })
    }

    function generatePassword() {
        yubiKey.generateStaticPw(keyboardLayout, function (res) {
            passwordInput.text = res
        })
    }

    RegExpValidator {
        id: modHexValidator
        regExp: /[cbdefghijklnrtuvCBDEFGHIJKLMNRTUV]{1,38}$/
    }

    RegExpValidator {
        id: usLayoutValidator
        regExp: /[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"#\$%&'\(\)\*\+,-\.\/:;<=>\?@\[\]\^_{}\|~]{1,38}$/
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("OTP"), SlotUtils.slotNameCapitalized(
                    views.selectedSlot), qsTr("Static Password")]
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Password")
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: passwordInput
                Layout.fillWidth: true
                validator: allowNonModhex.checked ? usLayoutValidator : modHexValidator
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            CustomButton {
                id: generatePasswordBtn
                text: qsTr("Generate")
                onClicked: generatePassword()
                toolTipText: qsTr("Generate a random password")
            }
        }
        CheckBox {
            id: allowNonModhex
            text: qsTr("Allow any character")
            onCheckedChanged: passwordInput.text = ""
            font.pixelSize: constants.h3
            Material.foreground: yubicoBlue
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("By default only modhex characters are allowed, enable this option to allow any (US Layout) characters")
        }

        ButtonsBar {
            finishCallback: finish
            finishEnabled: passwordInput.acceptableInput
            finishTooltip: qsTr("Finish and write the configuration to the YubiKey")
        }
    }
}
