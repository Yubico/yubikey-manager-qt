import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    ColumnLayout {
        Layout.margins: 20
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("Select Credential Type")
        }

        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("OTP")
                action: views.otp
            }
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: SlotUtils.slotNameCapitalized(views.selectedSlot)
                action: views.otp
            }
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("Select Credential Type")
                active: true
            }
        }

        ButtonGroup {
            id: configViewOptions
            buttons: typeColumn.children
        }

        GridLayout {
            id: typeColumn
            Layout.fillWidth: true
            Layout.leftMargin: 20
            columns: 2
            RadioButton {
                id: otpBtn
                text: qsTr("Yubico OTP")
                checked: true
                property var view: otpYubiOtpView
                font.pointSize: constants.h3
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a Yubico OTP credential.")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: chalRespBtn
                text: qsTr("Challenge-response")
                font.pointSize: constants.h3
                KeyNavigation.tab: staticBtn
                property var view: otpChalRespView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a Challenge-response credential.")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: staticBtn
                text: qsTr("Static password")
                font.pointSize: constants.h3
                KeyNavigation.tab: oathHotpBtn
                property var view: otpStaticPasswordView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a static password.")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: oathHotpBtn
                text: qsTr("OATH-HOTP")
                font.pointSize: constants.h3
                KeyNavigation.tab: backBtn
                property var view: otpOathHotpView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a OATH-HOTP credential.")
                Material.foreground: yubicoBlue
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
                icon.source: "../images/back.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
            }
            Button {
                id: nextBtn
                text: qsTr("Next")
                highlighted: true
                onClicked: views.push(configViewOptions.checkedButton.view)
                icon.source: "../images/next.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
            }
        }
    }
}
