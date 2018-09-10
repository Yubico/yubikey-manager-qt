import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.3

ColumnLayout {

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
                                                       views.otpFailedToConfigureErrorPopup(
                                                                   resp.error)
                                                   }
                                               }
                                           })
    }

    OtpSlotAlreadyConfiguredPopup {
        id: otpSlotAlreadyConfigured
        onAccepted: programChallengeResponse()
    }

    ColumnLayout {
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("Challenge-response")
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
                text: qsTr("Challenge-response")
                active: true
            }
        }

        RowLayout {
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
                    regExp: /([0-9a-fA-F]{2}){1,20}$/
                }
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Secret key can be a up to 40 characters (20 bytes) hex value.")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Button {
                id: generateBtn
                text: qsTr("Generate")
                Layout.fillWidth: false
                onClicked: generateKey()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Generate a random Secret Key.")
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
        }
        CheckBox {
            id: requireTouchCb
            enabled: yubiKey.serial
            text: qsTr("Require touch")
            font.pointSize: constants.h3
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("YubiKey will require a touch for the challenge-response operation.")
            Material.foreground: yubicoBlue
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
                id: finnishBtn
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
