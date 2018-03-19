import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {
    width: 350
    id: confColumn

    property string keyboardLayout: allowNonModhex.checked ? 'US' : 'MODHEX'

    RegExpValidator {
        id: modHexValidator
        regExp: /[cbdefghijklnrtuvCBDEFGHIJKLMNRTUV]{1,38}$/
    }

    RegExpValidator {
        id: usLayoutValidator
        regExp: /[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"#\$%&'\(\)\*\+,-\.\/:;<=>\?@\[\]\^_{}\|~]{1,38}$/
    }

    Label {

        text: qsTr("Configure static password for ") + SlotUtils.slotNameCapitalized(
                  selectedSlot)
        font.bold: true
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }

    Label {
        text: qsTr("When triggered, the YubiKey will output a fixed password.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }
    Label {
        id: desc
        text: qsTr("To avoid problems with different keyboard layouts, only the following characters are allowed by default: cbdefghijklnrtuv")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }
    GroupBox {
        title: "Password"
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: passwordInput
                    Layout.fillWidth: true
                    font.family: "Courier"
                    validator: allowNonModhex.checked ? usLayoutValidator : modHexValidator
                }
                Button {
                    text: qsTr("Generate")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: generatePassword()
                }
            }
            CheckBox {
                id: allowNonModhex
                text: qsTr("Allow any character.")
                checked: false
                onCheckedChanged: passwordInput.text = ""
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Button {
            text: qsTr("Back")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            text: qsTr("Finish")
            enabled: passwordInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onAccepted: programStaticPassword()
    }

    function finish() {
        if (slotsConfigured[selectedSlot - 1]) {
            warning.open()
        } else {
            programStaticPassword()
        }
    }

    function generatePassword() {
        device.generate_static_pw(keyboardLayout, function (res) {
            passwordInput.text = res
        })
    }

    function programStaticPassword() {
        device.program_static_password(selectedSlot, passwordInput.text,
                                       keyboardLayout, function (error) {
                                           if (!error) {
                                               confirmConfigured.open()
                                           } else {
                                               if (error === 3) {
                                                   writeError.open()
                                               }
                                           }
                                       })
    }
}
