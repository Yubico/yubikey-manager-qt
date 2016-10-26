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
    signal goToChallengeResponse
    signal goToStaticPassword
    signal goToOathHotp

    Text {
        textFormat: Text.StyledText
        text: "<h2>" + qsTr("Configure ") + SlotUtils.slotNameCapitalized(selectedSlot) + "</h2> <p>Select the type of functionality to configure:</p>"
    }
    RowLayout {
        ColumnLayout {
            id: typeColumn
            ExclusiveGroup {
                id: typeAlternatives
            }
            RadioButton {
                text: qsTr("Yubico OTP")
                exclusiveGroup: typeAlternatives
                checked: true
                property string name: "otp"
                property string desc: qsTr("Programs a one-time-password credential using the Yubico OTP protocol.")
            }
            RadioButton {
                text: qsTr("Challenge-response")
                exclusiveGroup: typeAlternatives
                property string name: "challengeResponse"
                property string desc: qsTr("Programs a HMAC-SHA1 credential, which can be used for local authentication or encryption.")
            }
            RadioButton {
                text: qsTr("Static password")
                exclusiveGroup: typeAlternatives
                property string name: "staticPassword"
                property string desc: qsTr("Stores a fixed password, which will be output each time you touch the button.")
            }
            RadioButton {
                text: qsTr("OATH-HOTP")
                exclusiveGroup: typeAlternatives
                property string name: "oathHotp"
                property string desc: qsTr("Stores a numeric one-time-password using the OATH-HOTP standard.")
            }
        }
        Item {
            width: minimumWidth - typeColumn.width - margins * 2
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                wrapMode: Text.Wrap
                text: typeAlternatives.current.desc
                verticalAlignment: Text.AlignVCenter
            }
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
            goToChallengeResponse()
            break
        case "staticPassword":
            goToStaticPassword()
            break
        case "oathHotp":
            goToOathHotp()
            break
        }
    }
}
