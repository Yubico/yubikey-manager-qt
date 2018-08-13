import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

ColumnLayout {

    property string lockCode: lockCodeInput.text
    property bool configurationLocked

    objectName: "interfaces"
    Component.onCompleted: load()

    function configureInterfaces() {
        views.lock()
        yubiKey.write_config(getEnabledUsbApplications(),
                             getEnabledNfcApplications(), lockCode,
                             function (resp) {
                                 if (resp.success) {
                                     views.pop()
                                 } else {
                                     console.log(resp.error)
                                 }
                                 views.unlock()
                             })
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

    function lockCodeProvidedIfNeeded() {
        return yubiKey.configurationLocked ? lockCodeInput.text.length > 0 : true
    }

    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Label {
            text: qsTr("Interfaces")
            color: yubicoBlue
            font.pointSize: constants.h1
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            GroupBox {
                id: usbGroupBox

                label: Label {
                    text: "USB"
                    lineHeight: 0.5
                    font.pointSize: constants.h2
                    color: yubicoBlue
                }
                background: Rectangle {
                    border.color: "transparent"
                    color: app.color
                }
                GridLayout {
                    columnSpacing: 0
                    rowSpacing: 0
                    anchors.leftMargin: -10
                    anchors.left: parent.left
                    columns: 3
                    CheckBox {
                        text: "OTP"
                        id: otpUsb
                    }
                    CheckBox {
                        text: "FIDO2"
                        id: fido2Usb
                    }
                    CheckBox {
                        text: "FIDO U2F"
                        id: u2fUsb
                    }
                    CheckBox {
                        text: "OpenPGP"
                        id: pgpUsb
                    }
                    CheckBox {
                        text: "PIV"
                        id: pivUsb
                    }
                    CheckBox {
                        text: "OATH"
                        id: oathUsb
                    }
                }
            }
            GroupBox {
                id: nfcGroupBox
                label: Label {
                    text: "NFC"
                    lineHeight: 0.5
                    font.pointSize: constants.h2
                    color: yubicoBlue
                }

                background: Rectangle {
                    border.color: "transparent"
                    color: app.color
                }

                GridLayout {
                    anchors.leftMargin: -10
                    anchors.left: parent.left
                    columns: 3
                    columnSpacing: 0
                    rowSpacing: 0
                    CheckBox {
                        id: otpNfc
                        text: "OTP"
                    }
                    CheckBox {
                        id: fido2Nfc
                        text: "FIDO2"
                    }
                    CheckBox {
                        id: u2fNfc
                        text: "FIDO U2F"
                    }
                    CheckBox {
                        id: pgpNfc
                        text: "OpenPGP"
                    }
                    CheckBox {
                        id: pivNfc
                        text: "PIV"
                    }
                    CheckBox {
                        id: oathNfc
                        text: "OATH"
                    }
                }
            }
        }

        Label {
            text: 'Lock Code'
            visible: configurationLocked
            color: yubicoBlue
            font.pointSize: constants.h3
        }
        TextField {
            id: lockCodeInput
            visible: configurationLocked
            Layout.fillWidth: true
            echoMode: TextInput.Password
        }

        RowLayout {
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Button {
                enabled: validCombination() && lockCodeProvidedIfNeeded()
                text: qsTr("Save Configuration")
                highlighted: true
                onClicked: configureInterfaces()
            }
        }
    }
}
