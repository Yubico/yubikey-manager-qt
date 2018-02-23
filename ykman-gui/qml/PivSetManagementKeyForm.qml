import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "utils.js" as Utils

ColumnLayout {
    property var device
    readonly property bool hasDevice: (device && device.hasDevice
                                       && device.piv) || false
    readonly property bool usePinAsKey: tabs.currentIndex == 0
    readonly property bool pinIsKeyCurrently: device.piv
                                              && device.piv.has_protected_key
                                              || false
    property alias requireTouch: requireTouchCheckbox.checked

    property string newManagementKeyInputText

    signal changeSuccessful

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
            title: "Personal"
            anchors.margins: 12

            ColumnLayout {
                Label {
                    text: "PIN will be used as management key."
                }
            }
        }

        Tab {
            id: enterpriseTab
            title: "Enterprise"
            anchors.margins: 12

            ColumnLayout {
                id: foo

                Label {
                    text: "A management key separate from the PIN will be created."
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
            text: 'Default'
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
        }
    }

    RowLayout {
        CheckBox {
            id: requireTouchCheckbox
            text: qsTr("Require touch")
        }

        Item {
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Ok")
            onClicked: submit()
        }
    }

    function showError(title, text) {
        errorDialog.title = title
        errorDialog.text = text
        errorDialog.open()
    }

    function showMessage(title, text) {
        messageDialog.title = title
        messageDialog.text = text
        messageDialog.open()
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
                var message = usePinAsKey ? 'Successfully set new management key protected by PIN.' : 'Successfully set new management key.';
                var extra = requireTouch ? '\n\nTouch is required to use the new management key.' : '';
                showMessage('Management key set', message + extra);

                changeSuccessful()
            } else if (result.failure.authenticate) {
                showError('Failed to change management key', 'Incorrect current management key.')
            } else if (result.failure.parseCurrentKey) {
                showError('Bad input', 'Invalid current management key: ' + result.message)
            } else if (result.failure.parseNewKey) {
                showError('Bad input', 'Invalid new management key: ' + result.message)
            } else if (result.failure.newKeyLength) {
                showError('Bad input', 'New management key must be exactly 48 characters.')
            } else {
                showError('Failed to change management key', result.message)
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

}
