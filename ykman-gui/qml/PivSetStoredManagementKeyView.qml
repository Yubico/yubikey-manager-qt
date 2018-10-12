import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property bool isBusy: false
    readonly property bool hasProtectedKey: yubiKey.piv.has_protected_key

    function finish() {
        isBusy = true
        yubiKey.piv_change_mgm_key(
            function(resp) {
                isBusy = false
                touchYubiKey.close()

                if (resp.success) {
                    pivSuccessPopup.open()
                    views.pivPinManagement()

                } else if (resp.error === 'bad_format') {
                    pivError.show(qsTr(
                        "Current management key must be exactly %1 hexadecimal characters.")
                            .arg(constants.pivManagementKeyHexLength))

                } else if (resp.error === 'wrong_key') {
                    pivError.show(qsTr("Wrong current management key."))

                } else if (resp.error === 'key_required') {
                    pivError.show(qsTr("Please enter the current management key."))

                } else if (resp.error === 'wrong_pin') {
                    pin.clear()
                    pivError.show(qsTr('Wrong PIN, %1 tries left.').arg(resp.tries_left))

                } else if (resp.error === 'blocked') {
                    pivError.show(qsTr('PIN is blocked.'))
                    views.pop()

                } else if (resp.error === 'pin_required') {
                    pivError.show(qsTr("Please enter the PIN."))

                } else if (resp.message) {
                    pivError.show(resp.message)

                } else {
                    console.log('Unknown failure:', resp.error)
                    pivError.show(qsTr('Unknown failure.'))
                }
            },
            pin.text,
            currentManagementKey.text,
            false,
            requireTouch.checked,
            touchYubiKey.open,
            true
        )
    }

    function inputDefaultPin() {
        pin.text = constants.pivDefaultPin
    }

    function inputDefaultManagementKey() {
        currentManagementKey.text = constants.pivDefaultManagementKey
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Set PIN as Management Key")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Configure PINs")
                    }, {
                        text: qsTr("Management Key Type")
                    }, {
                        text: qsTr("PIN as Management Key")
                    }]
            }
        }

        ColumnLayout {
            width: parent.width

            RowLayout {
                visible: !hasProtectedKey

                Label {
                    text: qsTr("Current management key:")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
                TextField {
                    id: currentManagementKey
                    Layout.fillWidth: true
                    selectByMouse: true
                    selectionColor: yubicoGreen
                    maximumLength: constants.pivManagementKeyHexLength
                    validator: RegExpValidator {
                        regExp: /[0-9a-f]*/
                    }
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Management key must be exactly 48 hexadecimal digits.")
                }
                CustomButton {
                    id: defaultManagementKeyBtn
                    text: qsTr("Default")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: inputDefaultManagementKey()
                    toolTipText: qsTr("Input the default PIV management key")
                }
            }

            RowLayout {
                Label {
                    text: qsTr("PIN:")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
                TextField {
                    id: pin
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    selectByMouse: true
                    selectionColor: yubicoGreen
                }
                CustomButton {
                    id: defaultPinBtn
                    text: qsTr("Default")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: inputDefaultPin()
                    toolTipText: qsTr("Input the default PIV PIN")
                }
            }

            CheckBox {
                id: requireTouch
                text: qsTr("Require touch")
                Layout.fillWidth: true
            }
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
                id: nextBtn
                text: qsTr("Finish")
                highlighted: true
                onClicked: finish()
                iconSource: "../images/next.svg"
                enabled: pin.text.length > 0 && (!currentManagementKey.visible || currentManagementKey.length == constants.pivManagementKeyHexLength)
            }
        }
    }
}
