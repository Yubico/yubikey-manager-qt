import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import "slotutils.js" as SlotUtils

ColumnLayout {

    ColumnLayout {
        Layout.margins: 20
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("Select Credential Type")
        }

        RowLayout {
            Label {
                text: qsTr("Home")
                color: yubicoGreen
            }

            BreadCrumbSeparator {
            }
            Label {
                text: qsTr("OTP")
                color: yubicoGreen
            }
            BreadCrumbSeparator {
            }

            Label {
                text: SlotUtils.slotNameCapitalized(views.selectedSlot)
                color: yubicoGreen
            }
            BreadCrumbSeparator {
            }

            Label {
                text: qsTr("Select Credential Type")
                color: yubicoGrey
            }
        }

        ButtonGroup {
            id: configViewOptions
            buttons: typeColumn.children
        }

        GridLayout {
            id: typeColumn
            Layout.fillWidth: true

            columns: 2
            RadioButton {
                id: otpBtn
                text: qsTr("Yubico OTP")
                checked: true
                property var view: otpYubiOtpView
            }
            RadioButton {
                id: chalRespBtn
                text: qsTr("Challenge-response")
                KeyNavigation.tab: staticBtn
                property var view: otpChalRespView
            }
            RadioButton {
                id: staticBtn
                text: qsTr("Static password")
                KeyNavigation.tab: oathHotpBtn
                property var view: otpStaticPasswordView
            }
            RadioButton {
                id: oathHotpBtn
                text: qsTr("OATH-HOTP")
                KeyNavigation.tab: backBtn
                property var view: otpOathHotpView
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
            }
            Button {
                id: nextBtn
                text: qsTr("Next")
                highlighted: true
                onClicked: views.push(configViewOptions.checkedButton.view)
            }
        }
    }
}
