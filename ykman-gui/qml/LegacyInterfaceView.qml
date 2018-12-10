import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.2

ColumnLayout {
    objectName: "interfaces"
    StackView.onActivating: load()
    function load() {
        otp.checked = Utils.includes(yubiKey.usbInterfacesEnabled, 'OTP')
        fido.checked = Utils.includes(yubiKey.usbInterfacesEnabled, 'FIDO')
        ccid.checked = Utils.includes(yubiKey.usbInterfacesEnabled, 'CCID')
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
        yubiKey.setMode(getEnabledInterfaces(), function (resp) {
            if (resp.success) {
                if (!yubiKey.canWriteConfig) {
                    reInsertYubiKey.open()
                } else {
                    views.pop()
                }
            } else {
                snackbarError.show(
                            qsTr("Failed to configure interfaces. Make sure the YubiKey does not have restricted access."))
            }
        })
    }

    function configurationHasChanged() {
        var enabledYubiKeyUsbInterfaces = JSON.stringify(
                    yubiKey.usbInterfacesEnabled.sort())
        var enabledUiUsbInterfaces = JSON.stringify(
                    getEnabledInterfaces().sort())
        return enabledYubiKeyUsbInterfaces !== enabledUiUsbInterfaces
    }

    function validCombination() {
        return otp.checked || fido.checked || ccid.checked
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("Interfaces")]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true

            GridLayout {
                columns: 3
                RowLayout {
                    Layout.columnSpan: 3
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                    Label {
                        text: qsTr("USB")
                        color: yubicoBlue
                        font.pixelSize: constants.h2
                    }
                }
                CheckBox {
                    id: otp
                    enabled: yubiKey.otpInterfaceSupported()
                    text: qsTr("OTP")
                    font.pixelSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle OTP interface over USB")
                    Material.foreground: yubicoBlue
                }
                CheckBox {
                    id: fido
                    enabled: yubiKey.fidoInterfaceSupported()
                    text: qsTr("FIDO")
                    font.pixelSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle FIDO interface over USB")
                    Material.foreground: yubicoBlue
                }
                CheckBox {
                    id: ccid
                    enabled: yubiKey.ccidInterfaceSupported()
                    text: qsTr("CCID (Smart Card)")
                    font.pixelSize: constants.h3
                    checkable: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle CCID interface over USB")
                    Material.foreground: yubicoBlue
                }
            }
        }

        ButtonsBar {
            finishCallback: configureInterfaces
            finishEnabled: configurationHasChanged() && validCombination()
            finishText: qsTr("Save Interfaces")
            finishTooltip: qsTr("Finish and save interfaces configuration to YubiKey")
        }
    }
}
