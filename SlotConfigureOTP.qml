import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

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

    Text {
        textFormat: Text.StyledText
        text: "<h2>Configure YubiKey OTP</h2><br/><p>When triggered, the YubiKey will output a one time password.</p>"
    }

    GridLayout {
        columns: 3
        Text {
            text: qsTr("Public ID")
        }
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
            text: qsTr("Use serial number")
            onCheckedChanged: useSerial()
        }
        Text {
            text: qsTr("Private ID")
        }
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
        Text {
            text: qsTr("Secret key")
        }
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
            onClicked: programOTP()
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
                                   // TODO: Handle errors, access code case.
                                   console.log(error)
                               }
                           })
    }

    MessageDialog {
        id: confirmConfigured
        icon: StandardIcon.Information
        title: "Slot configured"
        text: "The slot is now configured."
        standardButtons: StandardButton.Ok
        onAccepted: {
            goToOverview()
        }
    }
}
