import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {
    width: 350
    id: confColumn
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
                    validator: RegExpValidator {
                        regExp: /[cbdefghijklnrtuvCBDEFGHIJKLMNRTUV]{1,38}$/
                    }
                }
                Button {
                    text: qsTr("Generate")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: generatePassword()
                }
            }

            Label {
                id: desc
                width: parent.width
                text: qsTr("To avoid problems with different keyboard layouts, only the following characters are allowed: cbdefghijklnrtuv")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
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
        device.generate_static_pw(function (res) {
            passwordInput.text = res
        })
    }

    function programStaticPassword() {
        device.program_static_password(selectedSlot, passwordInput.text,
                                       function (error) {
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
