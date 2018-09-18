import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

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
                fido2SuccessPopup.open()
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

    Fido2GeneralErrorPopup {
        id: fido2TooLongError
        error: qsTr("Too long PIN, maximum size is 128 bytes.")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
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
        }
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Label {
                text: qsTr("New PIN")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
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
                text: qsTr("Confirm PIN")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
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
                text: qsTr("Set PIN")
                highlighted: true
                onClicked: setPin()
                toolTipText: qsTr("Finish and set the FIDO2 PIN")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
