import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "utils.js" as Utils

ColumnLayout {
    property var device

    readonly property bool acceptableInput: acceptablePin
    readonly property bool acceptablePin: !pinInput.enabled || pinInput.acceptableInput
    readonly property bool hasDevice: (device && device.hasDevice
                                       && device.piv) || false
    readonly property bool usePinAsKey: tabs.currentIndex == 0
    readonly property bool pinIsKeyCurrently: device.piv
                                              && device.piv.has_protected_key
                                              || false
    property alias requireTouch: requireTouchCheckbox.checked

    property string newManagementKeyInputText

    signal canceled
    signal changeSuccessful(bool pinAsKey, bool requireTouch)

    Layout.minimumHeight: tabs.Layout.minimumHeight
    Layout.minimumWidth: tabs.Layout.minimumWidth

    TabView {
        id: tabs
        Layout.fillWidth: true

        Layout.minimumHeight: Utils.sum(Utils.pick(contentItem.children, 'implicitHeight'))
        Layout.minimumWidth: Utils.sum(Utils.pick(contentItem.children, 'implicitWidth'))

        Component.onCompleted: {
            tabs.currentIndex = 1
            tabs.currentIndex = 0
        }

        Tab {
            id: personalTab
            title: qsTr("Personal")
            anchors.margins: margins

            ColumnLayout {
                Label {
                    text: qsTr("PIN will be used as management key.")
                }
            }
        }

        Tab {
            id: enterpriseTab
            title: qsTr("Enterprise")
            anchors.margins: margins

            ColumnLayout {
                id: foo

                Label {
                    text: qsTr("A management key separate from the PIN will be created.")
                }

                Label {
                    text: qsTr("New management key:")
                }

                TextField {
                    id: newManagementKeyInput
                    maximumLength: 48
                    focus: true
                    Layout.fillWidth: true

                    onTextChanged: setNewManagementKeyInput(text) // Root can't reference TabView children directly

                    validator: RegExpValidator {
                        regExp: /[0-9a-f]{48}/
                    }
                }

                RowLayout {
                    Button {
                        text: qsTr("Randomize")
                        onClicked: {
                            device.piv_generate_random_mgm_key(function (key) {
                                newManagementKeyInput.text = key
                            })
                        }
                    }

                    Button {
                        text: qsTr("Copy to clipboard")
                        onClicked: copyToClipboard(newManagementKeyInput.text)
                    }
                }
            }
        }
    }

    RowLayout {

        Label {
            Layout.fillWidth: true
            enabled: !pinIsKeyCurrently
            text: qsTr("Current management key:")
        }

        Label {
            Layout.alignment: Qt.AlignRight
            font.italic: true
            text: qsTr("PIN is currently used as key.")
            visible: pinIsKeyCurrently
        }
    }

    RowLayout {
        TextField {
            id: currentManagementKeyInput
            enabled: !pinIsKeyCurrently
            maximumLength: 48
            Layout.fillWidth: true

            validator: RegExpValidator {
                regExp: /[0-9a-f]{48}/
            }
        }

        Button {
            text: qsTr('Default')
            enabled: currentManagementKeyInput.enabled
            onClicked: currentManagementKeyInput.text = '010203040506070801020304050607080102030405060708'
        }
    }

    RowLayout {
        enabled: pinIsKeyCurrently || usePinAsKey

        Label {
            text: qsTr("PIN:")
        }

        TextField {
            id: pinInput
            echoMode: TextInput.Password
            validator: RegExpValidator {
                regExp: /.+/
            }
        }
    }

    CheckBox {
        id: requireTouchCheckbox
        text: qsTr("Require touch")
    }

    RowLayout {
        Button {
            text: qsTr("Cancel")
            onClicked: canceled()
        }

        Item {
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Ok")
            enabled: acceptableInput
            onClicked: submit()
        }
    }

    function showError(title, text) {
        errorDialog.title = title
        errorDialog.text = text
        errorDialog.open()
    }

    function setNewManagementKeyInput(value) {
        newManagementKeyInputText = value
    }

    function submit() {
        var pin = pinInput.enabled ? pinInput.text : null
        var currentKey = currentManagementKeyInput.enabled ? currentManagementKeyInput.text : null
        var newKey = usePinAsKey ? null : newManagementKeyInputText

        function mainCallback(result) {

            touchYubiKeyPrompt.close()
            if (result.success) {
                changeSuccessful(usePinAsKey, requireTouch)
            } else if (result.failure.keyRequired) {
                showError(qsTr('Bad input'), qsTr('Current management key is missing.'))
            } else if (result.failure.parseKey) {
                showError(qsTr('Bad input'), qsTr('Current management key is invalid: %1').arg(result.message))
            } else if (result.failure.keyAuthentication) {
                showError(qsTr('Failed to change management key'), qsTr('Current management key is incorrect.'))
            } else if (result.failure.parseNewKey) {
                showError(qsTr('Bad input'), qsTr('Invalid new management key: %1').arg(result.message))
            } else if (result.failure.newKeyLength) {
                showError(qsTr('Bad input'), qsTr('New management key must be exactly 48 characters.'))
            } else {
                showError(qsTr('Failed to change management key'), result.message)
            }
        }
        function touchCallback() {
            touchYubiKeyPrompt.show()
        }

        device.piv_change_mgm_key(mainCallback, pin, currentKey, newKey,
                                  requireTouch, touchCallback, usePinAsKey)
    }

    MessageDialog {
        id: errorDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

    Shortcut {
      sequence: 'Return'
      enabled: acceptableInput
      onActivated: submit()
    }

}
