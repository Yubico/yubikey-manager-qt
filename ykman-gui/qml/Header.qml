import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    spacing: 0
    width: app.width
    function activeKeyLbl() {
        if (!yubiKey.hasDevice || views.isShowingHomeView) {
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
                font.pixelSize: constants.h4
            }   
            CustomButton {

                flat: true
                text: qsTr("Help")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                iconSource: "../images/help.svg"
                toolTipText: qsTr("Visit Yubico Support in your web browser")
                onClicked: yubiKey.isAdmin ? helpPopup.show(
                    qsTr("Help"), qsTr(
                        "Visit https://www.yubico.com/kb for support with YubiKey Manager")) : Qt.openUrlExternally("https://www.yubico.com/kb")
                font.pixelSize: constants.h4
            }
            CustomButton {
                flat: true
                text: qsTr("About")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                iconSource: "../images/info.svg"
                toolTipText: qsTr("About YubiKey Manager")
                onClicked: aboutPage.open()
                font.pixelSize: constants.h4
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
        }
        TopMenuButton {
            text: qsTr("Home")
            onClicked: views.home()
            enabled: yubiKey.hasDevice
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
                    enabled: yubiKey.isEnabledOverUsb('OTP')
                    text: qsTr("OTP")
                    Material.foreground: yubicoBlue
                    onClicked: views.otp()
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure OTP Application")
                    font.family: constants.fontFamily
                    font.pixelSize: constants.h3
                }
                MenuItem {
                    enabled: yubiKey.isEnabledOverUsb('FIDO2')
                    text: qsTr("FIDO2")
                    onClicked: views.fido2()
                    Material.foreground: yubicoBlue
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure FIDO2 Application")
                    font.family: constants.fontFamily
                    font.pixelSize: constants.h3
                }
                MenuItem {
                    enabled: yubiKey.isEnabledOverUsb('PIV')
                    text: qsTr("PIV")
                    onClicked: {
                        if (!views.isShowingPiv)
                            views.piv()
                    }
                    Material.foreground: yubicoBlue
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Configure PIV Application")
                    font.family: constants.fontFamily
                    font.pixelSize: constants.h3
                }
            }
        }
        TopMenuButton {
            text: qsTr("Interfaces")
            enabled: yubiKey.hasDevice && yubiKey.canChangeInterfaces()
            onClicked: views.configureInterfaces()
            toolTipText: qsTr("Configure what is available over different interfaces")
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