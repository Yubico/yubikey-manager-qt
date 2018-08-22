import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.3

ColumnLayout {

    property string lockCode: lockCodePopup.lockCode
    property bool configurationLocked

    readonly property var applications: [{
            "id": 'OTP'
        }, {
            "id": 'FIDO2'
        }, {
            "id": 'U2F',
            "name": qsTr('FIDO U2F')
        }, {
            "id": 'OPGP',
            "name": qsTr('OpenPGP')
        }, {
            "id": 'PIV'
        }, {
            "id": 'OATH'
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
    }

    function validCombination() {
        return usbEnabled.length >= 1
    }

    function toggleNfc() {
        if (nfcEnabled.length < 1) {
            nfcEnabled = Utils.pick(applications, 'id')
        } else {
            nfcEnabled = []
        }
    }

    function toggleUsb() {
        if (usbEnabled.length < 2) {
            usbEnabled = Utils.pick(applications, 'id')
        } else {
            usbEnabled = [applications[0].id]
        }
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
            Layout.bottomMargin: 20
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
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.visible: containsMouse
                            ToolTip.text: qsTr("Toggle USB availability. At least one USB application is required.")
                            onClicked: toggleUsb()
                        }
                    }
                }
                background: Rectangle {
                    border.color: "transparent"
                    color: app.color
                }
                GridLayout {
                    columnSpacing: 0
                    rowSpacing: -15
                    anchors.leftMargin: -10
                    anchors.left: parent.left
                    columns: 2

                    Repeater {
                        model: applications
                        CheckBox {
                            checked: getUsbEnabledState(modelData.id)
                            onCheckedChanged: setUsbEnabledState(modelData.id,
                                                                 checked)
                            text: modelData.name || modelData.id
                            font.pointSize: constants.h3
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle %1 availability over USB.").arg(
                                              modelData.name || modelData.id)
                            Material.foreground: yubicoBlue
                        }
                    }
                }
            }
            GroupBox {
                id: nfcGroupBox
                label: Row {
                    spacing: 5
                    Label {
                        id: nfcLbl
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
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.visible: containsMouse
                            ToolTip.text: qsTr("Toggle NFC availability.")
                            onClicked: toggleNfc()
                        }
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
                    rowSpacing: -15

                    Repeater {
                        model: applications
                        CheckBox {
                            checked: getNfcEnabledState(modelData.id)
                            onCheckedChanged: setNfcEnabledState(modelData.id,
                                                                 checked)
                            text: modelData.name || modelData.id
                            font.pointSize: constants.h3
                            ToolTip.delay: 1000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle %1 availability over NFC.").arg(
                                              modelData.name || modelData.id)
                            Material.foreground: yubicoBlue
                        }
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
                icon.source: "../images/finish.svg"
                icon.width: 16
                icon.height: 16
                font.capitalization: Font.MixedCase
                font.family: "Helvetica Neue"
            }
        }
    }
}
