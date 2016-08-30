import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
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

    Text {
        textFormat: Text.StyledText
        text: "<h2>" + qsTr("Configure ") + SlotUtils.slotNameCapitalized(selectedSlot) + "</h2> <p>Select the type of functionality to configure:</p>"
    }
    RowLayout {
        ColumnLayout {
            ExclusiveGroup {
                id: typeAlternatives
            }
            RadioButton {
                text: qsTr("YubiKey OTP")
                exclusiveGroup: typeAlternatives
                checked: true
                property string name: "otp"
                property string desc: qsTr("Programs a onte-time-passwordcredential using the YubiKey OTP protocol.")
            }
            RadioButton {
                text: qsTr("Challenge-response")
                exclusiveGroup: typeAlternatives
                property string name: "challengeResponse"
                property string desc: qsTr("Programs a HMAC-SHA1 credential,which can be used for local authentication or encryption.")
            }
            RadioButton {
                text: qsTr("Static password")
                exclusiveGroup: typeAlternatives
                property string name: "staticPassword"
                property string desc: qsTr("Stores a fixed password,which will be output each time you touch the button.")
            }
            RadioButton {
                text: qsTr("OATH-HOTP")
                exclusiveGroup: typeAlternatives
                property string name: "oathHotp"
                property string desc: qsTr("Stores a numeric one-time-password using the OATH-HOTP standard.")
            }
        }

        Text {
            text: typeAlternatives.current.desc
            verticalAlignment: Text.AlignVCenter
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: goToSlotStatus()
        }
        Button {
            text: qsTr("Next")
            onClicked: openProgramCredDialog(typeAlternatives.current.name)
        }
    }

    function openProgramCredDialog(typeName) {
        switch (typeName) {
        case "otp":
            goToConfigureOTP()
            break
        case "challengeResponse":
            console.log("challengeResponse")
            break
        case "staticPassword":
            console.log("staticPassword")
            break
        case "oathHotp":
            console.log("oathHotp")
            break
        }
    }
}
