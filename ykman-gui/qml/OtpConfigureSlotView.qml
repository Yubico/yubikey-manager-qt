import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import "slotutils.js" as SlotUtils

ColumnLayout {

    function heading() {
        return qsTr("Configure ") + SlotUtils.slotNameCapitalized(
                    views.selectedSlot)
    }

    ColumnLayout {
        Layout.margins: 20
        Layout.fillWidth: true
        Layout.fillHeight: true

        Label {
            text: heading()
            font.pointSize: 36
            color: yubicoBlue
            Layout.fillWidth: true
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
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
