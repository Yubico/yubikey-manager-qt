import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {

    property var device
    property var slotsEnabled: [false, false]
    property int selectedSlot
    signal configureSlot(int slot)
    signal updateStatus
    signal goToOverview
    signal goToSelectType
    signal goToSlotStatus
    signal goToConfigureOTP
    signal goToChallengeResponse
    signal goToStaticPassword
    signal goToOathHotp

    Text {
        text: "Configure Yubico OTP for " + SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Text {
        text: "When triggered, the YubiKey will output a one time password."
    }


    GroupBox {
        title: qsTr("Public ID")
        Layout.fillWidth: true
        ColumnLayout {

         RowLayout{
             TextField {
                 id: publicIdInput
                 implicitWidth: 110
                 font.family: "Courier"
                 validator: RegExpValidator {
                     regExp: /[cbdefghijklnrtuv]{12}$/
                 }
             }
             CheckBox {
                 id: useSerialCb
                 anchors.margins: 5
                 anchors.left: publicIdInput.right
                 text: qsTr("Use encoded serial number")
                 onCheckedChanged: useSerial()
             }
         }
         RowLayout {
             Text {
                 text: "The Public ID can contain the following characters: cbdefghijklnrtuv."
             }
         }

        }
    }

    GroupBox {
        title: qsTr("Private ID")
        Layout.fillWidth: true
        ColumnLayout {

             RowLayout{
                 TextField {
                     id: privateIdInput
                     implicitWidth: 110
                     font.family: "Courier"
                     validator: RegExpValidator {
                         regExp: /[0-9a-fA-F]{12}$/
                     }
                 }
                 Button {
                     anchors.margins: 5
                     text: qsTr("Generate")
                     anchors.left: privateIdInput.right
                     onClicked: generatePrivateId()
                 }
             }
             RowLayout {
                 Text {
                     text: "The Private ID contains 12 hexadecimal characters."
                 }
             }
        }
    }

    GroupBox {
        title: qsTr("Secret key")
        Layout.fillWidth: true
        ColumnLayout {

             RowLayout{
                 TextField {
                     id: secretKeyInput
                     implicitWidth: 260
                     font.family: "Courier"
                     validator: RegExpValidator {
                         regExp: /[0-9a-fA-F]{32}$/
                     }
                 }
                 Button {
                     anchors.margins: 5
                     anchors.left: secretKeyInput.right
                     text: qsTr("Generate")
                     onClicked: generateKey()
                 }
             }
             RowLayout {
                 Text {
                     text: "The Secret key contains 32 hexadecimal characters."
                 }
             }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: goToSelectType()
        }
        Button {
            text: qsTr("Finish")
            enabled: publicIdInput.acceptableInput
                     && privateIdInput.acceptableInput
                     && secretKeyInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onAccepted: programOTP()
    }

    function finish() {
        if (slotsEnabled[selectedSlot - 1]) {
            warning.open()
        } else {
            programOTP()
        }
    }

    function useSerial() {
        if (useSerialCb.checked) {
            device.serial_modhex(function (res) {
                publicIdInput.text = res
            })
        }
    }

    function generatePrivateId() {
        device.random_uid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateKey() {
        device.random_key(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function programOTP() {
        device.program_otp(selectedSlot, publicIdInput.text,
                           privateIdInput.text, secretKeyInput.text,
                           function (error) {
                               if (!error) {
                                   updateStatus()
                                   confirmConfigured.open()
                               } else {
                                   if (error === 3) {
                                     writeError.open()
                                   }
                               }
                           })
    }

}
