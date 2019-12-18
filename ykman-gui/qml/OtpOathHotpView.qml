import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    function finish() {
        if (secretKeyInput.validInput) {
            if (views.selectedSlotConfigured()) {
                otpConfirmOverwrite(programOathHotp)
            } else {
                programOathHotp()
            }
        } else {
            snackbarError.qsTr('Secret key contains invalid base32 digits.')
        }
    }

    function programOathHotp() {
        yubiKey.programOathHotp(views.selectedSlot, secretKeyInput.text,
                                digits.currentText, function (resp) {
                                    if (resp.success) {
                                        views.otp()
                                        snackbarSuccess.show(
                                                    qsTr("Configured OATH-HOTP credential"))
                                    } else {
                                        if (resp.error_id === 'write error') {
                                            views.otpWriteError()
                                        } else {
                                            views.otpFailedToConfigureErrorPopup(
                                                        resp)
                                        }
                                    }
                                })
    }

    CustomContentColumn {
        ViewHeader {
            breadcrumbs: [qsTr("OTP"), SlotUtils.slotNameCapitalized(
                    views.selectedSlot), qsTr("OATH-HOTP")]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: constants.contentTopMargin * 0.3
                text: qsTr("Secret key")
                font.pixelSize: constants.h3
                color: yubicoBlue
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.fillWidth: true

                CustomTextField {
                    id: secretKeyInput
                    Layout.fillWidth: true
                    toolTipText: qsTr("Secret key must be a base32 encoded value")

                    property bool validInput: /^[ 2-7a-zA-Z]+=*$/.test(text)
                    property string invalidChars: text.match(/[^ 2-7a-zA-Z=]*/g).join('')

                    color: validInput ? "#000000" : yubicoRed
                }

                Label {
                    text: secretKeyInput.invalidChars && qsTr("Invalid base32 digits: %1").arg(secretKeyInput.invalidChars)
                    font.pixelSize: constants.h4
                    color: yubicoRed
                }
            }
        }

        RowLayout {
            Label {
                text: qsTr("Digits")
                font.pixelSize: constants.h3
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

        ButtonsBar {
            finishCallback: finish
            finishEnabled: secretKeyInput.acceptableInput && secretKeyInput.validInput
            finishTooltip: qsTr("Finish and write the configuration to the YubiKey")
        }
    }
}
