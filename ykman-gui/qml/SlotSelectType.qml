import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import "slotutils.js" as SlotUtils

ColumnLayout {

    function pushConfigView(viewOption) {
        switch (viewOption) {
        case "otp":
            stack.push({
                           item: slotConfigureOTP,
                           immediate: true
                       })
            break
        case "challengeResponse":
            stack.push({
                           item: slotConfigureChallengeResponse,
                           immediate: true
                       })
            break
        case "staticPassword":
            stack.push({
                           item: slotConfigureStaticPassword,
                           immediate: true
                       })
            break
        case "oathHotp":
            stack.push({
                           item: slotConfigureOathHotp,
                           immediate: true
                       })
            break
        }
    }

    Label {
        text: qsTr("Configure ") + SlotUtils.slotNameCapitalized(selectedSlot)
        font.bold: true
    }

    Label {
        text: qsTr("Choose which function to configure in this slot:")
    }

    ColumnLayout {
        id: typeColumn
        ExclusiveGroup {
            id: configViewOptions
        }
        RadioButton {
            text: qsTr("Yubico OTP")
            exclusiveGroup: configViewOptions
            checked: true
            property string name: "otp"
            property string desc: qsTr("Programs a one-time password credential using the Yubico OTP protocol.")
        }
        RadioButton {
            text: qsTr("Challenge-response")
            exclusiveGroup: configViewOptions
            property string name: "challengeResponse"
            property string desc: qsTr("Programs a HMAC-SHA1 credential, that can be used for local authentication or encryption.")
        }
        RadioButton {
            text: qsTr("Static password")
            exclusiveGroup: configViewOptions
            property string name: "staticPassword"
            property string desc: qsTr("Stores a fixed password, which will be output each time you touch the button.")
        }
        RadioButton {
            text: qsTr("OATH-HOTP")
            exclusiveGroup: configViewOptions
            property string name: "oathHotp"
            property string desc: qsTr("Stores a numeric one-time password using the OATH-HOTP standard.")
        }
    }

    RowLayout {
        Item {
            Layout.fillWidth: true
            implicitHeight: desc.implicitHeight
            Label {
                id: desc
                width: parent.width
                wrapMode: Text.Wrap
                text: configViewOptions.current.desc
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            text: qsTr("Next")
            onClicked: pushConfigView(configViewOptions.current.name)
        }
    }
}
