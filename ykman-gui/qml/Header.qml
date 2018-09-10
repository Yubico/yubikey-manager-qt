import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.3

ColumnLayout {
    spacing: 0
    function activeKeyLbl() {
        if (!yubiKey.hasDevice) {
            return ""
        } else {
            if (yubiKey.serial) {
                return yubiKey.name + " (" + yubiKey.serial + ")"
            } else {
                return yubiKey.name
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        Layout.rightMargin: 10
        Layout.topMargin: 10
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            Label {
                text: activeKeyLbl()
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
            }
            Button {
                flat: true
                text: "Help"
                font.pointSize: 12
                font.capitalization: Font.MixedCase
                font.family: constants.fontFamily
                Material.foreground: yubicoBlue
                display: AbstractButton.TextBesideIcon
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                icon.source: "../images/help.svg"
                icon.width: 16
                icon.height: 16
                onClicked: Qt.openUrlExternally("https://www.yubico.com/kb")
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Visit Yubico Support in your web browser.")
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Image {
            id: yubicoLogo
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            Layout.maximumWidth: 150
            fillMode: Image.PreserveAspectFit
            source: "../images/yubico-logo.svg"
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: Qt.openUrlExternally("https://www.yubico.com/")
                ToolTip.delay: 1000
                ToolTip.visible: containsMouse
                ToolTip.text: qsTr("Visit yubico.com in your web browser.")
            }
        }
        TopMenuButton {
            text: qsTr("Home")
            onClicked: views.home()
        }
        TopMenuButton {
            text: qsTr("Applications")
            Layout.fillWidth: false
            enabled: yubiKey.hasDevice
            onClicked: applicationsMenu.open()

            Menu {
                id: applicationsMenu
                y: parent.height
                Material.elevation: 1
                MenuItem {
                    enabled: yubiKey.otpEnabled()
                    text: qsTr("OTP")
                    Material.foreground: yubicoBlue
                    onClicked: views.otp()
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure the OTP Application.")
                    font.family: constants.fontFamily
                }
                MenuItem {
                    enabled: yubiKey.fido2Enabled()
                    text: qsTr("FIDO2")
                    onClicked: views.fido2()
                    Material.foreground: yubicoBlue
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure the FIDO2 Application.")
                    font.family: constants.fontFamily
                }
            }
        }
        TopMenuButton {
            text: qsTr("Interfaces")
            enabled: yubiKey.hasDevice && yubiKey.canChangeInterfaces()
            onClicked: views.configureInterfaces()
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Configure what is available over different interfaces.")
        }
    }
    Rectangle {
        id: headerBorder
        Layout.minimumHeight: 4
        Layout.maximumHeight: 4
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: yubicoGreen
    }
}
