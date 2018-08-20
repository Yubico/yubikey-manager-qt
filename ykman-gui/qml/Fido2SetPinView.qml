import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

ColumnLayout {
    readonly property alias chosenPin: newPin.text
    readonly property bool pinMatches: newPin.text === confirmPin.text

    function validPin() {
        return (pinMatches) && (chosenPin.length >= constants.fido2PinMinLength)
                && (chosenPin.length <= constants.fido2PinMaxLength)
    }

    function setPin() {
        yubiKey.fido_set_pin(chosenPin, function (resp) {
            if (resp.success) {
                fido2SetPinSucces.open()
            } else {
                if (resp.error === 'too long') {
                    fido2TooLongError.open()
                } else {
                    fido2GeneralError.error = resp.error
                    fido2GeneralError.open()
                }
            }
        })
    }
    Fido2SuccessPopup {
        id: fido2SetPinSucces
        message: qsTr("Success! The FIDO2 PIN was set.")
    }

    Fido2GeneralErrorPopup {
        id: fido2TooLongError
        error: qsTr("Too long PIN, maximum size is 128 bytes.")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("Set PIN")
        }

        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("FIDO2")
                action: views.fido2
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("Set PIN")
                active: true
            }
        }

        Label {
            text: qsTr("New PIN")
            font.pointSize: constants.h3
            color: yubicoBlue
        }

        TextField {
            id: newPin
            Layout.fillWidth: true
            echoMode: TextInput.Password
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("The FIDO2 PIN must be at least 4 characters long.")
            selectByMouse: true
            selectionColor: yubicoGreen
        }

        Label {
            text: qsTr("Confirm PIN")
            font.pointSize: constants.h3
            color: yubicoBlue
        }
        TextField {
            id: confirmPin
            Layout.fillWidth: true
            echoMode: TextInput.Password
            selectByMouse: true
            selectionColor: yubicoGreen
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            Button {
                text: qsTr("Cancel")
                onClicked: views.pop()
            }
            Button {
                enabled: validPin()
                text: qsTr("Set PIN")
                highlighted: true
                onClicked: setPin()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and set the FIDO2 PIN.")
            }
        }
    }
}
