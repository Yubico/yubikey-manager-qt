import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.2

ColumnLayout {
    objectName: "interfaces"

    property string lockCode: lockCodePopup.lockCode

    property var newApplicationsEnabledOverUsb: []
    property var newApplicationsEnabledOverNfc: []

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

    Component.onCompleted: load()

    function configureInterfaces() {
        if (yubiKey.configurationLocked) {
            lockCodePopup.open()
        } else {
            writeInterfaces()
        }
    }

    function writeInterfaces() {
        views.lock()
        yubiKey.write_config(newApplicationsEnabledOverUsb,
                             newApplicationsEnabledOverNfc, lockCode,
                             function (resp) {
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
                    yubiKey.applicationsEnabledOverUsb.sort())
        var enabledUiUsb = JSON.stringify(newApplicationsEnabledOverUsb.sort())
        var enabledYubiKeyNfc = JSON.stringify(
                    yubiKey.applicationsEnabledOverNfc.sort())
        var enabledUiNfc = JSON.stringify(newApplicationsEnabledOverNfc.sort())

        return enabledYubiKeyUsb !== enabledUiUsb
                || enabledYubiKeyNfc !== enabledUiNfc
    }

    function toggleEnabledOverUsb(applicationId, enabled) {
        if (enabled) {
            newApplicationsEnabledOverUsb = Utils.including(
                        newApplicationsEnabledOverUsb, applicationId)
        } else {
            newApplicationsEnabledOverUsb = Utils.without(
                        newApplicationsEnabledOverUsb, applicationId)
        }
    }

    function toggleEnabledOverNfc(applicationId, enabled) {
        if (enabled) {
            newApplicationsEnabledOverNfc = Utils.including(
                        newApplicationsEnabledOverNfc, applicationId)
        } else {
            newApplicationsEnabledOverNfc = Utils.without(
                        newApplicationsEnabledOverNfc, applicationId)
        }
    }

    function load() {
        // Populate initial state of checkboxes
        for (var i = 0; i < applications.length; i++) {
            usbCheckBoxes.itemAt(i).checked = yubiKey.isEnabledOverUsb(
                        applications[i].id) && yubiKey.isSupportedOverUSB(
                        applications[i].id)
            nfcCheckBoxes.itemAt(i).checked = yubiKey.isEnabledOverNfc(
                        applications[i].id) && yubiKey.isSupportedOverNfc(
                        applications[i].id)
        }
    }

    function validCombination() {
        return newApplicationsEnabledOverUsb.length >= 1
    }

    function toggleNfc() {
        if (newApplicationsEnabledOverNfc.length < 1) {
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
        if (newApplicationsEnabledOverUsb.length < 2) {
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
                items: [
                    { text: qsTr("Interfaces") },
                ]
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60
            id: mainRow

            GridLayout {
                visible: yubiKey.supportsUsbConfiguration()
                columns: 2
                RowLayout {
                    spacing: 8
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                    }
                    Label {
                        text: qsTr("USB")
                        color: yubicoBlue
                        font.pixelSize: constants.h2
                    }
                }
                CustomButton {
                    text: newApplicationsEnabledOverUsb.length < 2 ? qsTr("Enable all") : qsTr(
                                                                         "Disable all")
                    flat: true
                    onClicked: toggleUsb()
                    toolTipText: qsTr("Toggle all availability over USB (at least one USB application is required)")
                }

                Repeater {
                    id: usbCheckBoxes
                    model: applications
                    CheckBox {
                        enabled: yubiKey.isSupportedOverUSB(modelData.id)
                        Layout.bottomMargin: -20
                        onCheckedChanged: toggleEnabledOverUsb(modelData.id,
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
                visible: yubiKey.supportsNfcConfiguration()
                         && yubiKey.supportsUsbConfiguration()
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
                visible: yubiKey.supportsNfcConfiguration()
                columns: 2
                RowLayout {
                    spacing: 8
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/contactless.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                    }
                    Label {
                        text: qsTr("NFC")
                        font.pixelSize: constants.h2
                        color: yubicoBlue
                    }
                }
                CustomButton {
                    text: newApplicationsEnabledOverNfc.length < 1 ? qsTr("Enable all") : qsTr(
                                                                         "Disable all")
                    flat: true
                    onClicked: toggleNfc()
                    toolTipText: qsTr("Toggle all availability over NFC")
                }

                Repeater {
                    id: nfcCheckBoxes
                    model: applications
                    CheckBox {
                        enabled: yubiKey.isSupportedOverNfc(modelData.id)
                        Layout.bottomMargin: -20
                        onCheckedChanged: toggleEnabledOverNfc(modelData.id,
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
