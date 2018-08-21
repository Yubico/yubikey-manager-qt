import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

ColumnLayout {

    property string lockCode: lockCodePopup.lockCode
    property bool configurationLocked

    objectName: "interfaces"
    Component.onCompleted: load()

    function configureInterfaces() {
        if (configurationLocked) {
            lockCodePopup.open()
        } else {
            writeInterfaces()
        }
    }

    function writeInterfaces() {
        views.lock()
        yubiKey.write_config(getEnabledUsbApplications(),
                             getEnabledNfcApplications(), lockCode,
                             function (resp) {
                                 if (resp.success) {
                                     views.unlock()
                                     views.home()
                                 } else {
                                     console.log(resp.error)
                                     views.unlock()
                                     errorLockCodePopup.open()
                                 }
                             })
    }

    function configurationHasChanged() {
        var enabledYubiKeyUsb = JSON.stringify(
                    yubiKey.enabledUsbApplications.sort())
        var enabledUiUsb = JSON.stringify(getEnabledUsbApplications().sort())
        var enabledYubiKeyNfc = JSON.stringify(
                    yubiKey.enabledNfcApplications.sort())
        var enabledUiNfc = JSON.stringify(getEnabledNfcApplications().sort())

        return enabledYubiKeyUsb !== enabledUiUsb
                || enabledYubiKeyNfc !== enabledUiNfc
    }

    function getEnabledUsbApplications() {
        var enabledApplications = []
        if (otpUsb.checked) {
            enabledApplications.push('OTP')
        }
        if (fido2Usb.checked) {
            enabledApplications.push('FIDO2')
        }
        if (u2fUsb.checked) {
            enabledApplications.push('U2F')
        }
        if (pivUsb.checked) {
            enabledApplications.push('PIV')
        }
        if (pgpUsb.checked) {
            enabledApplications.push('OPGP')
        }
        if (oathUsb.checked) {
            enabledApplications.push('OATH')
        }
        return enabledApplications
    }

    function getEnabledNfcApplications() {
        var enabledApplications = []
        if (otpNfc.checked) {
            enabledApplications.push('OTP')
        }
        if (fido2Nfc.checked) {
            enabledApplications.push('FIDO2')
        }
        if (u2fNfc.checked) {
            enabledApplications.push('U2F')
        }
        if (pivNfc.checked) {
            enabledApplications.push('PIV')
        }
        if (pgpNfc.checked) {
            enabledApplications.push('OPGP')
        }
        if (oathNfc.checked) {
            enabledApplications.push('OATH')
        }
        return enabledApplications
    }

    function load() {
        configurationLocked = yubiKey.configurationLocked

        otpUsb.checked = Utils.includes(yubiKey.enabledUsbApplications, 'OTP')
        fido2Usb.checked = Utils.includes(yubiKey.enabledUsbApplications,
                                          'FIDO2')
        u2fUsb.checked = Utils.includes(yubiKey.enabledUsbApplications, 'U2F')
        pivUsb.checked = Utils.includes(yubiKey.enabledUsbApplications, 'PIV')
        pgpUsb.checked = Utils.includes(yubiKey.enabledUsbApplications, 'OPGP')
        oathUsb.checked = Utils.includes(yubiKey.enabledUsbApplications, 'OATH')

        otpNfc.checked = Utils.includes(yubiKey.enabledNfcApplications, 'OTP')
        fido2Nfc.checked = Utils.includes(yubiKey.enabledNfcApplications,
                                          'FIDO2')
        u2fNfc.checked = Utils.includes(yubiKey.enabledNfcApplications, 'U2F')
        pivNfc.checked = Utils.includes(yubiKey.enabledNfcApplications, 'PIV')
        pgpNfc.checked = Utils.includes(yubiKey.enabledNfcApplications, 'OPGP')
        oathNfc.checked = Utils.includes(yubiKey.enabledNfcApplications, 'OATH')
    }

    function validCombination() {
        return otpUsb.checked || fido2Usb.checked || u2fUsb.checked
                || pivUsb.checked || pgpUsb.checked || oathUsb.checked
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height
        Layout.preferredWidth: app.width

        Heading1 {
            text: qsTr("Interfaces")
        }

        BreadCrumbRow {

            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }

            BreadCrumb {
                text: qsTr("Interfaces")
                active: true
            }
        }

        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            GroupBox {
                id: usbGroupBox

                label: Row {
                    spacing: 5
                    Label {
                        id: label
                        text: "USB"
                        lineHeight: 0.5
                        color: yubicoBlue
                        font.pointSize: constants.h2
                    }
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                }
                background: Rectangle {
                    border.color: "transparent"
                    color: app.color
                }
                GridLayout {
                    columnSpacing: 0
                    rowSpacing: -10
                    anchors.leftMargin: -10
                    anchors.left: parent.left
                    columns: 2
                    CheckBox {
                        text: qsTr("OTP")
                        font.pointSize: constants.h3
                        id: otpUsb
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OTP availability over USB.")
                    }
                    CheckBox {
                        text: qsTr("FIDO2")
                        font.pointSize: constants.h3
                        id: fido2Usb
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr(
                                          "Toggle FIDO2 availability over USB.")
                    }
                    CheckBox {
                        text: qsTr("FIDO U2F")
                        font.pointSize: constants.h3
                        id: u2fUsb
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle FIDO U2F availability over USB.")
                    }
                    CheckBox {
                        text: qsTr("OpenPGP")
                        id: pgpUsb
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OpenPGP availability over USB.")
                    }
                    CheckBox {
                        text: qsTr("PIV")
                        id: pivUsb
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle PIV availability over USB.")
                    }
                    CheckBox {
                        text: qsTr("OATH")
                        id: oathUsb
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OATH availability over USB.")
                    }
                }
            }
            GroupBox {
                id: nfcGroupBox
                label: Row {
                    spacing: 5
                    Label {
                        text: qsTr("NFC")
                        lineHeight: 0.5
                        color: yubicoBlue
                        font.pointSize: constants.h2
                    }
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/wifi.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                }

                background: Rectangle {
                    border.color: "transparent"
                    color: app.color
                }

                GridLayout {
                    anchors.leftMargin: -10
                    anchors.left: parent.left
                    columns: 2
                    columnSpacing: 0
                    rowSpacing: -10
                    CheckBox {
                        id: otpNfc
                        text: qsTr("OTP")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OTP availability over NFC.")
                    }
                    CheckBox {
                        id: fido2Nfc
                        text: qsTr("FIDO2")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr(
                                          "Toggle FIDO2 availability over NFC.")
                    }
                    CheckBox {
                        id: u2fNfc
                        text: qsTr("FIDO U2F")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle FIDO U2F availability over NFC.")
                    }
                    CheckBox {
                        id: pgpNfc
                        text: qsTr("OpenPGP")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OpenPGP availability over NFC.")
                    }
                    CheckBox {
                        id: pivNfc
                        text: qsTr("PIV")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle PIV availability over NFC.")
                    }
                    CheckBox {
                        id: oathNfc
                        text: qsTr("OATH")
                        font.pointSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle OATH availability over NFC.")
                    }
                }
            }
        }

        InterFaceLockCodePopup {
            id: lockCodePopup
            onAccepted: writeInterfaces()
        }

        InterfacesErrorPopup {
            id: errorLockCodePopup
        }

        RowLayout {
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                enabled: configurationHasChanged() && validCombination()
                text: qsTr("Save Interfaces")
                highlighted: true
                onClicked: configureInterfaces()
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Finish and save interfaces configuration to YubiKey.")
            }
        }
    }
}
