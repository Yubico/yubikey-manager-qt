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

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Static Password")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("OTP")
                    }, {
                        text: SlotUtils.slotNameCapitalized(
                                    views.selectedSlot) || ""
                    }, {
                        text: qsTr("Static Password")
                    }]
            }
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
                id: finishBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: passwordInput.acceptableInput
                toolTipText: qsTr("Finish and write the configuration to the YubiKey")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
