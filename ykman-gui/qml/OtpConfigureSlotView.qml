import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Select Credential Type")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("OTP")
                    }, {
                        text: SlotUtils.slotNameCapitalized(
                                    views.selectedSlot) || ""
                    }]
            }
        }

        ButtonGroup {
            id: configViewOptions
            buttons: typeColumn.children
        }

        GridLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            id: typeColumn
            Layout.fillWidth: true
            Layout.leftMargin: 20
            columns: 2
            RadioButton {
                id: otpBtn
                text: qsTr("Yubico OTP")
                checked: true
                property var view: otpYubiOtpView
                font.pixelSize: constants.h3
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a Yubico OTP credential")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: chalRespBtn
                text: qsTr("Challenge-response")
                font.pixelSize: constants.h3
                KeyNavigation.tab: staticBtn
                property var view: otpChalRespView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a Challenge-response credential")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: staticBtn
                text: qsTr("Static password")
                font.pixelSize: constants.h3
                KeyNavigation.tab: oathHotpBtn
                property var view: otpStaticPasswordView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a static password")
                Material.foreground: yubicoBlue
            }
            RadioButton {
                id: oathHotpBtn
                text: qsTr("OATH-HOTP")
                font.pixelSize: constants.h3
                KeyNavigation.tab: backBtn
                property var view: otpOathHotpView
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configure a OATH-HOTP credential")
                Material.foreground: yubicoBlue
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            BackButton {
            }
            CustomButton {
                id: nextBtn
                text: qsTr("Next")
                highlighted: true
                onClicked: views.push(configViewOptions.checkedButton.view)
                iconSource: "../images/next.svg"
            }
        }
    }
}
