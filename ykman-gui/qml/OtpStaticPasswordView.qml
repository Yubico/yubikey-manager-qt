import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string keyboardLayoutName: "MODHEX"
    property RegExpValidator keyboardLayoutValidator: modHexValidator

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpConfirmOverwrite(programStaticPassword)
        } else {
            programStaticPassword()
        }
    }

    function programStaticPassword() {
        yubiKey.programStaticPassword(views.selectedSlot, passwordInput.text,
                                      keyboardLayoutName, function (resp) {
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
        yubiKey.generateStaticPw(keyboardLayoutName, function (resp) {
            if (resp.success) {
                passwordInput.text = resp.password
            } else {
                snackbarError.showResponseError(resp)
            }
        })
    }

    // Update these if the ykman scancodes change: https://github.com/Yubico/yubikey-manager/tree/51a7ae438c923189788a1e31d3de18d452131942/ykman/scancodes
    RegExpValidator { id: modHexValidator; regExp: /[bcdefghijklnrtuvBCDEFGHIJKLNRTUV]{1,38}$/ }
    RegExpValidator { id: usLayoutValidator; regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"\#\$%\&'`\(\)\*\+,\-\.\/:;<=>\?@\[\\\]\^_\{\}\|\~\ ]{1,38}$/ }
    RegExpValidator { id: ukLayoutValidator; regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@£\$%\&'`\(\)\*\+,\-\.\/:;<=>\?"\[\#\]\^_\{\}\~¬\ ]{1,38}$/ }
    RegExpValidator { id: deLayoutValidator; regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"\#\$%\&'\(\)\*\+,\-\.\/:;<=>\?\^_\ `§´ÄÖÜßäöü]{1,38}$/ }
    // U+007F : <control> DELETE [DEL] ("") is here because neither \x{007F} nor \u007F worked
    RegExpValidator { id: frLayoutValidator; regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\ !"\$%\&'\(\)\*\+,\-\.\/:;<=_£§°²µàçèéù]{1,38}$/ }
    RegExpValidator { id: itLayoutValidator; regExp: /[\ !"\#\$%\&'\(\)\*\+,\-\.\/0123456789:;<=>\?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\\\^_`abcdefghijklmnopqrstuvwxyz\|£§°çèéàìòù]{1,38}$/ }
    // U+00A0 : NO-BREAK SPACE [NBSP] (" ") is here because neither \x{00A0} nor \u00A0 worked
    RegExpValidator { id: bepoLayoutValidator; regExp: /[\ !"\#\$%'\(\)\*\+,\-\.\/0123456789:;=\?@ABCDEFGHIJKLMNOPQRSTUVWXYZ`abcdefghijklmnopqrstuvwxyz «°»ÀÇÈÉÊàçèéê]{1,38}$/ }
    RegExpValidator { id: normanLayoutValidator; regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"\#\$%\&'`\(\)\*\+,\-\.\/:;<=>\?@\[\\\]\^_\{\}\|\~\ ]{1,38}$/ }

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
            CustomTextField {
                id: passwordInput
                Layout.fillWidth: true
                validator: keyboardLayoutValidator
            }
            CustomButton {
                id: generatePasswordBtn
                text: qsTr("Generate")
                onClicked: generatePassword()
                toolTipText: qsTr("Generate a random password")
            }
        }

        RowLayout {
            spacing: 15
            Label {
                text: qsTr("Keyboard Layout")
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            ComboBox {
                textRole: "text"
                valueRole: "value"
                currentIndex: 0
                model: ListModel {
                    // https://stackoverflow.com/a/33161093/19020549
                    Component.onCompleted: {
                        append({"text": "MODHEX", value: modHexValidator});
                        append({"text": "US", value: usLayoutValidator});
                        append({"text": "UK", value: ukLayoutValidator});
                        append({"text": "DE", value: deLayoutValidator});
                        append({"text": "FR", value: frLayoutValidator});
                        append({"text": "IT", value: itLayoutValidator});
                        append({"text": "BEPO", value: bepoLayoutValidator});
                        append({"text": "NORMAN", value: normanLayoutValidator});
                    }
                }
                onActivated: {
                    keyboardLayoutName = currentText
                    keyboardLayoutValidator = currentValue
                    passwordInput.text = ""
                }
            }
        }

        ButtonsBar {
            finishCallback: finish
            finishEnabled: passwordInput.acceptableInput
            finishTooltip: qsTr("Finish and write the configuration to the YubiKey")
        }
    }
}
