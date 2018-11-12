import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property var breadcrumbs
    property string heading
    property bool hasNewManagementKeyInput
    property bool storeManagementKey

    property bool hasPinInput: hasProtectedKey
    property bool isBusy: false

    readonly property bool hasProtectedKey: yubiKey.piv.has_protected_key
    readonly property bool validNewManagementKey: (!hasNewManagementKeyInput
        || newManagementKey.text.length == constants.pivManagementKeyHexLength)

    function clearDefaultManagementKey() {
        if (useDefaultCurrentManagementKeyCheckbox.checked) {
            currentManagementKey.clear()
            useDefaultCurrentManagementKeyCheckbox.checked = false
        }
    }

    function clearPin() {
        pin.clear()
        useDefaultPinCheckbox.checked = false
    }

    function generateManagementKey() {
        yubiKey.piv_generate_random_mgm_key(function(key) {
            newManagementKey.text = key
        })
    }

    function inputDefaultPin() {
        pin.text = constants.pivDefaultPin
    }

    function toggleUseDefaultCurrentPin() {
        if (useDefaultPinCheckbox.checked) {
            pin.text = constants.pivDefaultPin
        } else {
            pin.clear()
        }
    }

    function inputDefaultManagementKey() {
        currentManagementKey.text = constants.pivDefaultManagementKey
    }

    function toggleUseDefaultCurrentManagementKey() {
        if (useDefaultCurrentManagementKeyCheckbox.checked) {
            currentManagementKey.text = constants.pivDefaultManagementKey
        } else {
            currentManagementKey.clear()
        }
    }

    function finish(pin, currentManagementKey, newManagementKey) {
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

                } else if (resp.error === 'new_key_bad_length' || resp.error === 'new_key_bad_hex') {
                    pivError.show(qsTr(
                        "New management key must be exactly %1 hexadecimal characters.")
                            .arg(constants.pivManagementKeyHexLength))

                } else if (resp.error === 'wrong_key') {
                    clearDefaultManagementKey()
                    pivError.show(qsTr("Wrong current management key."))

                } else if (resp.error === 'key_required') {
                    pivError.show(qsTr("Please enter the current management key."))

                } else if (resp.error === 'wrong_pin') {
                    clearPin()
                    pivError.show(qsTr('Wrong PIN, %1 tries left.').arg(resp.tries_left))

                } else if (resp.error === 'blocked') {
                    pivError.show(qsTr('PIN is blocked.'))
                    if (hasProtectedKey) {
                        views.pivPinManagement()
                    } else {
                        views.pop()
                    }

                } else if (resp.error === 'pin_required') {
                    pivError.show(qsTr("Please enter the PIN."))

                } else if (resp.message) {
                    pivError.show(resp.message)

                } else {
                    console.log('Unknown failure:', resp.error)
                    pivError.show(qsTr('Unknown failure.'))
                }
            },
            pin,
            currentManagementKey,
            hasNewManagementKeyInput ? newManagementKey : false,
            touchYubiKey.open,
            storeManagementKey
        )
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: heading
            }

            BreadCrumbRow {
                items: breadcrumbs
            }
        }

        ColumnLayout {
            width: parent.width

            GridLayout {
                columns: 3

                Label {
                    text: qsTr("PIN:")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: hasPinInput
                }
                TextField {
                    id: pin
                    Layout.fillWidth: true
                    echoMode: enabled ? TextInput.Password : TextInput.Normal
                    selectByMouse: true
                    selectionColor: yubicoGreen
                    visible: hasPinInput
                    enabled: !useDefaultPinCheckbox.checked
                }
                CheckBox {
                    id: useDefaultPinCheckbox
                    text: qsTr("Use default")
                    onCheckedChanged: toggleUseDefaultCurrentPin()
                    font.pixelSize: constants.h3
                    Material.foreground: yubicoBlue
                    visible: hasPinInput
                }

                Label {
                    text: qsTr("Current Management Key:")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: !hasProtectedKey
                }
                TextField {
                    id: currentManagementKey
                    Layout.fillWidth: true
                    selectByMouse: true
                    selectionColor: yubicoGreen
                    visible: !hasProtectedKey
                    enabled: !useDefaultCurrentManagementKeyCheckbox.checked
                }
                CheckBox {
                    id: useDefaultCurrentManagementKeyCheckbox
                    text: qsTr("Use default")
                    onCheckedChanged: toggleUseDefaultCurrentManagementKey()
                    font.pixelSize: constants.h3
                    Material.foreground: yubicoBlue
                    visible: !hasProtectedKey
                }

                Label {
                    text: qsTr("New Management Key:")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: hasNewManagementKeyInput
                }
                TextField {
                    id: newManagementKey
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
                    visible: hasNewManagementKeyInput
                }
                CustomButton {
                    id: randomManagementKeyBtn
                    text: qsTr("Generate")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: generateManagementKey()
                    visible: hasNewManagementKeyInput
                }
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
                onClicked: finish(pin.text, currentManagementKey.text, newManagementKey.text)
                iconSource: "../images/next.svg"
                enabled: validNewManagementKey
            }
        }
    }
}
