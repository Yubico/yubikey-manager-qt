import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    readonly property alias chosenCurrentPin: currentPin.text
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    function validPin() {
        return (pinMatches) && (chosenPin.length >= constants.fido2PinMinLength)
                && (chosenPin.length <= constants.fido2PinMaxLength)
    }

    function changePin() {
        yubiKey.fido_change_pin(chosenCurrentPin, chosenPin, function (resp) {
            if (resp.success) {
                fido2SuccessPopup.open()
            } else {
                if (resp.error === 'too long') {
                    fido2TooLongError.open()
                } else if (resp.error === 'wrong pin') {
                    clearPinInputs()
                    fido2WrongPinError.open()
                } else if (resp.error === 'currently blocked') {
                    fido2CurrentlyBlockedError.open()
                } else if (resp.error === 'blocked') {
                    fido2BlockedError.open()
                } else {
                    fido2GeneralError.error = resp.error
                    fido2GeneralError.open()
                }
            }
        })
    }

    function clearPinInputs() {
        currentPin.text = ''
        newPin.text = ''
        confirmPin.text = ''
    }

    Fido2GeneralErrorPopup {
        id: fido2TooLongError
        error: qsTr("Too long PIN, maximum size is 128 bytes")
    }

    Fido2GeneralErrorPopup {
        id: fido2WrongPinError
        error: qsTr("The current PIN is wrong")
    }

    Fido2GeneralErrorPopup {
        id: fido2CurrentlyBlockedError
        error: qsTr("PIN authentication is currently blocked - Remove and re-insert your YubiKey")
    }

    Fido2GeneralErrorPopup {
        id: fido2BlockedError
        error: qsTr("PIN is blocked")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
    }

    CustomContentColumn {
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Change PIN")
            }

            BreadCrumbRow {
                items: [{
                        "text": qsTr("FIDO2"),
                        "action": views.fido2
                    }, {
                        "text": qsTr("Change PIN")
                    }]
            }
        }
        GridLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            columns: 2
            Layout.fillWidth: true
            Label {
                text: qsTr("Current PIN")
                font.pixelSize: constants.h3
                color: yubicoBlue
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            TextField {
                id: currentPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Label {
                text: qsTr("New PIN")
                font.pixelSize: constants.h3
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            TextField {
                id: newPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr(
                                  "The FIDO2 PIN must be at least 4 characters")
                selectByMouse: true
                selectionColor: yubicoGreen
            }
            Label {
                text: qsTr("Confirm new PIN")
                font.pixelSize: constants.h3
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            TextField {
                id: confirmPin
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectByMouse: true
                selectionColor: yubicoGreen
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            CustomButton {
                text: qsTr("Back")
                onClicked: views.fido2()
                iconSource: "../images/back.svg"
            }
            CustomButton {
                enabled: validPin()
                text: qsTr("Change PIN")
                highlighted: true
                onClicked: changePin()
                toolTipText: qsTr("Finish and change the FIDO2 PIN")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
