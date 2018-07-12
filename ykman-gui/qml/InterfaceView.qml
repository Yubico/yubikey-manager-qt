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
            Layout.fillWidth: true
            GridLayout {
                flow: GridLayout.LeftToRight
                columnSpacing: 20
                Layout.fillWidth: true
                //rowSpacing: -10
                columns: 7
                Label {
                }
                Label {
                    text: "OTP"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: yubicoBlue
                    font.pointSize: constants.h3
                }
                Label {
                    text: "FIDO2"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Label {
                    text: "FIDO U2F"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: yubicoBlue
                    font.pointSize: constants.h3
                }
                Label {
                    text: "OpenPGP"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Label {
                    text: "PIV"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Label {
                    text: "OATH"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Label {
                    text: "USB"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }

                CheckBox {
                    id: otpUsb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: fido2Usb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: u2fUsb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: pgpUsb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: pivUsb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: oathUsb
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: "NFC"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: false
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                CheckBox {
                    id: otpNfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: fido2Nfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: u2fNfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: pgpNfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: pivNfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CheckBox {
                    id: oathNfc
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
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
                text: qsTr("Cancel")
                onClicked: views.pop()
            }
            Button {
                enabled: validCombination() && lockCodeProvidedIfNeeded()
                text: qsTr("Save Configuration")
                highlighted: true
                onClicked: configureInterfaces()
            }
        }
    }
}
