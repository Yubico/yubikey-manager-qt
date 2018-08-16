import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

ColumnLayout {
    objectName: "interfaces"
    Component.onCompleted: load()
    function load() {
        otp.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'OTP')
        fido.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'FIDO')
        ccid.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'CCID')
    }

    function getEnabledInterfaces() {
        var interfaces = []
        if (otp.checked) {
            interfaces.push('OTP')
        }
        if (fido.checked) {
            interfaces.push('FIDO')
        }
        if (ccid.checked) {
            interfaces.push('CCID')
        }
        return interfaces
    }

    function configureInterfaces() {
        yubiKey.set_mode(getEnabledInterfaces(), function (error) {
            if (error) {
                console.log(error)
            } else {
                if (!yubiKey.canWriteConfig) {
                    reInsertYubiKey.open()
                } else {
                    views.pop()
                }
            }
        })
    }

    function configurationHasChanged() {
        var enabledYubiKeyUsbInterfaces = JSON.stringify(
                    yubiKey.enabledUsbInterfaces.sort())
        var enabledUiUsbInterfaces = JSON.stringify(
                    getEnabledInterfaces().sort())
        return enabledYubiKeyUsbInterfaces !== enabledUiUsbInterfaces
    }

    function validCombination() {
        return otp.checked || fido.checked || ccid.checked
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("USB Interfaces")
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
            Layout.fillWidth: true

            CheckBox {
                id: otp
                enabled: yubiKey.otpInterfaceSupported()
                text: qsTr("OTP")
                checkable: true
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Toggle OTP interface over USB.")
            }
            CheckBox {
                id: fido
                enabled: yubiKey.fidoInterfaceSupported()
                text: qsTr("FIDO")
                checkable: true
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Toggle FIDO interface over USB.")
            }
            CheckBox {
                id: ccid
                enabled: yubiKey.ccidInterfaceSupported()
                text: "CCID (Smart Card)"
                checkable: true
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Toggle CCID interface over USB.")
            }
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
