import QtQuick 2.5
import QtQuick.Controls 2.3
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

        Label {
            text: qsTr("<a href='https://www.yubico.com/kb' style='color:#284c61'>help</a>")
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
            Layout.alignment: Qt.AlignRight
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Layout.fillWidth: true
        Layout.rightMargin: 10
        Layout.topMargin: 10
        Label {
            text: activeKeyLbl()
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            color: yubicoBlue
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Image {
            id: yubicoLogo
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            Layout.maximumWidth: 150
            fillMode: Image.PreserveAspectFit
            source: "../images/yubico-logo.svg"
        }
        Button {
            text: qsTr("Home")
            onClicked: views.home()
            flat: true
            Material.foreground: yubicoBlue
        }
        Button {
            text: qsTr("Applications")
            Layout.fillWidth: false
            enabled: yubiKey.hasDevice
            Material.foreground: yubicoBlue
            onClicked: applicationsMenu.open()
            flat: true

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
                }
                MenuItem {
                    enabled: yubiKey.fido2Enabled()
                    text: qsTr("FIDO2")
                    onClicked: views.fido2()
                    Material.foreground: yubicoBlue
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure the FIDO2 Application.")
                }
            }
        }
        Button {
            text: qsTr("Interfaces")
            flat: true
            Material.foreground: yubicoBlue
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
