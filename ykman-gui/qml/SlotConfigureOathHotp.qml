import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {
    Keys.onTabPressed: secretKeyInput.forceActiveFocus()
    Keys.onEscapePressed: close()
    id: confColumn

    function finish() {
        if (slotsConfigured[selectedSlot - 1]) {
            warning.open()
        } else {
            programOathHotp()
        }
    }

    function programOathHotp() {
        device.program_oath_hotp(selectedSlot, secretKeyInput.text,
                                 digits.currentText, handleResponse)
    }

    function handleResponse(resp) {
        if (resp.success) {
            confirmConfigured.open()
        } else if (resp.error === 'Incorrect padding') {
            paddingError.open()
        } else if (resp.error === 'write error') {
            writeError.open()
        } else if (resp.error === 'key lengths >20 bytes not supported') {
            toLongKeyError.open()
        }
    }

    Label {
        text: qsTr("Configure HOTP credential for ") + SlotUtils.slotNameCapitalized(
                  selectedSlot)
        font.bold: true
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }

    Label {
        text: qsTr("When triggered, the YubiKey will output a HOTP code.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }
    GroupBox {
        title: qsTr("Secret Key")
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: secretKeyInput
                    KeyNavigation.tab: digits
                    Layout.fillWidth: true
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[ 2-7a-zA-Z]+=*/
                    }
                }
            }

            Label {
                text: qsTr("The Secret key should be encoded in base32.")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Label {
                    text: qsTr("Digits")
                }
                ComboBox {
                    id: digits
                    model: [6, 8]
                    KeyNavigation.tab: backBtn
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            id: backBtn
            KeyNavigation.tab: finishBtn
            text: qsTr("Back")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            id: finishBtn
            text: qsTr("Finish")
            KeyNavigation.tab: secretKeyInput
            enabled: secretKeyInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onYes: programOathHotp()
    }

    MessageDialog {
        id: paddingError
        icon: StandardIcon.Critical
        title: qsTr("Wrong padding")
        text: qsTr("The padding of the key is incorrect.")
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: toLongKeyError
        icon: StandardIcon.Critical
        title: qsTr("Secret Key is too long")
        text: qsTr("Secret key is too long.")
        standardButtons: StandardButton.Ok
    }
}
