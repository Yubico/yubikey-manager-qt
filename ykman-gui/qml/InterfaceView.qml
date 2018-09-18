import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string lockCode: lockCodePopup.lockCode
    property bool configurationLocked

    readonly property var applications: [{
            id: "OTP",
            name: qsTr("OTP")
        }, {
            id: "FIDO2",
            name: qsTr("FIDO2")
        }, {
            id: "U2F",
            name: qsTr("FIDO U2F")
        }, {
            id: "OPGP",
            name: qsTr("OpenPGP")
        }, {
            id: "PIV",
            name: qsTr("PIV")
        }, {
            id: "OATH",
            name: qsTr("OATH")
        }]
    property var usbEnabled: []
    property var nfcEnabled: []

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
        yubiKey.write_config(usbEnabled, nfcEnabled, lockCode, function (resp) {
            if (resp.success) {
                interfacesSuccessPopup.open()
                views.unlock()
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
        var enabledUiUsb = JSON.stringify(usbEnabled.sort())
        var enabledYubiKeyNfc = JSON.stringify(
                    yubiKey.enabledNfcApplications.sort())
        var enabledUiNfc = JSON.stringify(nfcEnabled.sort())

        return enabledYubiKeyUsb !== enabledUiUsb
                || enabledYubiKeyNfc !== enabledUiNfc
    }

    function setUsbEnabledState(applicationId, enabled) {
        if (enabled) {
            usbEnabled = Utils.including(usbEnabled, applicationId)
        } else {
            usbEnabled = Utils.without(usbEnabled, applicationId)
        }
    }

    function setNfcEnabledState(applicationId, enabled) {
        if (enabled) {
            nfcEnabled = Utils.including(nfcEnabled, applicationId)
        } else {
            nfcEnabled = Utils.without(nfcEnabled, applicationId)
        }
    }

    function getUsbEnabledState(applicationId) {
        return Utils.includes(usbEnabled, applicationId)
    }

    function getNfcEnabledState(applicationId) {
        return Utils.includes(nfcEnabled, applicationId)
    }

    function load() {
        configurationLocked = yubiKey.configurationLocked

        usbEnabled = yubiKey.enabledUsbApplications
        nfcEnabled = yubiKey.enabledNfcApplications

        // Populate initial state of checkboxes
        for (var i = 0; i < applications.length; i++) {
            usbCheckBoxes.itemAt(i).checked = getUsbEnabledState(
                        applications[i].id)
            nfcCheckBoxes.itemAt(i).checked = getNfcEnabledState(
                        applications[i].id)
        }
    }

    function validCombination() {
        return usbEnabled.length >= 1
    }

    function toggleNfc() {
        if (nfcEnabled.length < 1) {
            for (var i = 0; i < nfcCheckBoxes.count; i++) {
                nfcCheckBoxes.itemAt(i).checked = true
            }
        } else {
            for (var j = 0; j < nfcCheckBoxes.count; j++) {
                nfcCheckBoxes.itemAt(j).checked = false
            }
        }
    }

    function toggleUsb() {
        if (usbEnabled.length < 2) {
            for (var i = 0; i < usbCheckBoxes.count; i++) {
                usbCheckBoxes.itemAt(i).checked = true
            }
        } else {
            for (var j = 0; j < usbCheckBoxes.count; j++) {
                // Leave OTP by default, not allowed to have 0 USB enabled.
                if (usbCheckBoxes.itemAt(j).text !== 'OTP') {
                    usbCheckBoxes.itemAt(j).checked = false
                }
            }
        }
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
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
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60
            id: mainRow

            GridLayout {
                columns: 2
                RowLayout {
                    Label {
                        text: qsTr("USB")
                        color: yubicoBlue
                        font.pixelSize: constants.h2
                    }
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                }
                CustomButton {
                    text: usbEnabled.length < 2 ? qsTr("Enable all") : qsTr(
                                                      "Disable all")
                    flat: true
                    onClicked: toggleUsb()
                    toolTipText: qsTr("Toggle all availability over USB (at least one USB application is required)")
                }

                Repeater {
                    id: usbCheckBoxes
                    model: applications
                    CheckBox {
                        Layout.bottomMargin: -20
                        onCheckedChanged: setUsbEnabledState(modelData.id,
                                                             checked)
                        text: modelData.name || modelData.id
                        font.pixelSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle %1 availability over USB").arg(
                                          modelData.name || modelData.id)
                        Material.foreground: yubicoBlue
                    }
                }
            }

            Rectangle {
                id: separator
                Layout.minimumWidth: 1
                Layout.maximumWidth: 1
                Layout.maximumHeight: mainRow.height * 0.7
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yubicoGrey
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            GridLayout {
                columns: 2
                RowLayout {
                    Label {
                        text: qsTr("NFC")
                        font.pixelSize: constants.h2
                        color: yubicoBlue
                    }
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/wifi.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                    }
                }
                CustomButton {
                    text: nfcEnabled.length < 1 ? qsTr("Enable all") : qsTr(
                                                      "Disable all")

                    flat: true
                    onClicked: toggleNfc()
                    toolTipText: qsTr("Toggle all availability over NFC")
                }

                Repeater {
                    id: nfcCheckBoxes
                    model: applications
                    CheckBox {
                        Layout.bottomMargin: -20
                        onCheckedChanged: setNfcEnabledState(modelData.id,
                                                             checked)
                        text: modelData.name || modelData.id
                        font.pixelSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle %1 availability over NFC").arg(
                                          modelData.name || modelData.id)
                        Material.foreground: yubicoBlue
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

            CustomButton {
                enabled: configurationHasChanged() && validCombination()
                text: qsTr("Save Interfaces")
                highlighted: true
                onClicked: configureInterfaces()
                toolTipText: qsTr("Finish and save interfaces configuration to YubiKey")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
