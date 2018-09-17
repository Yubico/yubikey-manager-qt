import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string keyboardLayout: allowNonModhex.checked ? 'US' : 'MODHEX'

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpSlotAlreadyConfigured.open()
        } else {
            programStaticPassword()
        }
    }

    function programStaticPassword() {
        yubiKey.program_static_password(views.selectedSlot, passwordInput.text,
                                        keyboardLayout, function (resp) {
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

    function generatePassword() {
        yubiKey.generate_static_pw(keyboardLayout, function (res) {
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

    OtpSlotAlreadyConfiguredPopup {
        id: otpSlotAlreadyConfigured
        onAccepted: programStaticPassword()
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
                text: qsTr("Static Password")
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
                    text: qsTr("Static Password")
                    active: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Password")
                font.pointSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: passwordInput
                Layout.fillWidth: true
                validator: allowNonModhex.checked ? usLayoutValidator : modHexValidator
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Button {
                id: generatePasswordBtn
                text: qsTr("Generate")
                onClicked: generatePassword()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Generate a random password")
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
        }
        CheckBox {
            id: allowNonModhex
            text: qsTr("Allow any character")
            onCheckedChanged: passwordInput.text = ""
            font.pointSize: constants.h3
            Material.foreground: yubicoBlue
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("By default only modhex characters are allowed, enable this option to allow any (US Layout) characters")
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
                id: finishBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: passwordInput.acceptableInput
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and write the configuration to the YubiKey")
                icon.source: "../images/finish.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
            }
        }
    }
}
