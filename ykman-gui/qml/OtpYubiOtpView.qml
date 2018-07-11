import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

    function heading() {
        return qsTr("Configure ") + SlotUtils.slotNameCapitalized(
                    views.selectedSlot)
    }

    function useSerial() {
        if (useSerialCb.checked) {
            yubiKey.serial_modhex(function (res) {
                publicIdInput.text = res
            })
        }
    }

    function generatePrivateId() {
        yubiKey.random_uid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateKey() {
        yubiKey.random_key(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpSlotAlreadyConfigured.open()
        } else {
            programYubiOtp()
        }
    }

    function programYubiOtp() {
        yubiKey.program_otp(views.selectedSlot, publicIdInput.text,
                            privateIdInput.text, secretKeyInput.text,
                            function (resp) {
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
        onAccepted: programYubiOtp()
    }

    ColumnLayout {
        Layout.margins: 20

        Label {
            text: heading()
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            font.pointSize: 36
            color: yubicoBlue
        }
        Label {
            text: qsTr("Public ID")
            font.pointSize: 18
            color: yubicoBlue
        }
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: publicIdInput
                Layout.fillWidth: true
                enabled: !useSerialCb.checked
                validator: RegExpValidator {
                    regExp: /[cbdefghijklnrtuv]{12}$/
                }
            }
            CheckBox {
                id: useSerialCb
                enabled: yubiKey.serial
                text: qsTr("Use encoded serial number")
                onCheckedChanged: useSerial()
            }
        }
        Label {
            text: qsTr("Private ID")
            font.pointSize: 18
            color: yubicoBlue
        }
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: privateIdInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{12}$/
                }
            }
            Button {
                id: generatePrivateIdBtn
                text: qsTr("Generate")
                Layout.fillWidth: false
                onClicked: generatePrivateId()
            }
        }
        Label {
            text: qsTr("Secret key")
            font.pointSize: 18
            color: yubicoBlue
        }
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: secretKeyInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{32}$/
                }
            }
            Button {
                id: generateSecretKeyBtn
                text: qsTr("Generate")
                onClicked: generateKey()
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
            }
            Button {
                id: finnishBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                enabled: publicIdInput.acceptableInput
                         && privateIdInput.acceptableInput
                         && secretKeyInput.acceptableInput
            }
        }
    }
}
