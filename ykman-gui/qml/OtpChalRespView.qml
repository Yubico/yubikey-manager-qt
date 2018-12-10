import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    function generateKey() {
        yubiKey.randomKey(20, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpConfirmOverwrite(programChallengeResponse)
        } else {
            programChallengeResponse()
        }
    }

    function programChallengeResponse() {
        yubiKey.programChallengeResponse(views.selectedSlot,
                                         secretKeyInput.text,
                                         requireTouchCb.checked,
                                         function (resp) {
                                             if (resp.success) {
                                                 views.otpSuccess()
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

    CustomContentColumn {
        ViewHeader {
            breadcrumbs: [qsTr("OTP"), SlotUtils.slotNameCapitalized(
                    views.selectedSlot), qsTr("Challenge-response")]
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                text: qsTr("Secret key")
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            TextField {
                id: secretKeyInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /([0-9a-fA-F]{2}){1,20}$/
                }
                ToolTip.delay: 1000
                background.width: width
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Secret key can be a up to 40 characters (20 bytes) hex value")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            CustomButton {
                id: generateBtn
                text: qsTr("Generate")
                onClicked: generateKey()
                toolTipText: qsTr("Generate a random Secret Key")
            }
        }
        CheckBox {
            id: requireTouchCb
            enabled: yubiKey.serial
            text: qsTr("Require touch")
            font.pixelSize: constants.h3
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("YubiKey will require a touch for the challenge-response operation")
            Material.foreground: yubicoBlue
        }

        ButtonsBar {
            finishCallback: finish
            finishEnabled: secretKeyInput.acceptableInput
            finishTooltip: qsTr("Finish and write the configuration to the YubiKey")
        }
    }
}
