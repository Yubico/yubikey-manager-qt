import QtQuick 2.5
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
    signal goToStaticPassword
    signal goToOathHotp

    Text {
        textFormat: Text.StyledText
        text: "<h2>Configure static password</h2><br/><p>When triggered, the YubiKey will output a fixed password.</p><br/><p>To avoid problems with different keyboard layouts, the password should only contain modhex characters.<p>"
    }

    RowLayout {
        Text {
            text: qsTr("Password")
        }
        TextField {
            id: passwordInput
            implicitWidth: 280
            font.family: "Courier"
            validator: RegExpValidator {
                regExp: /[cbdefghijklnrtuv]{1,32}$/
            }
        }
        Button {
            anchors.margins: 5
            text: qsTr("Generate")
            anchors.left: passwordInput.right
            onClicked: generatePassword()
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
            enabled: passwordInput.acceptableInput
            onClicked: programStaticPassword()
        }
    }

    function generatePassword() {
        device.random_modhex(16, function (res) {
            passwordInput.text = res
        })
    }

    function programStaticPassword() {
        device.program_static_password(selectedSlot, passwordInput.text,
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
