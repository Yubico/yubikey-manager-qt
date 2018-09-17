import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: otpView

    property bool isBusy
    readonly property string slotIsConfigured: qsTr("This slot is configured.")
    readonly property string slotIsEmpty: qsTr("This slot is empty.")

    Component.onCompleted: load()

    function load() {
        isBusy = true
        yubiKey.slots_status(function (resp) {
            if (!resp.error) {
                views.slot1Configured = resp.status[0]
                views.slot2Configured = resp.status[1]
                views.selectedSlot = 0
                isBusy = false
            } else {
                if (resp.error === 'timeout') {
                    views.otpGeneralError(
                                qsTr("Failed to load OTP application."))
                } else {
                    views.otpGeneralError(resp.error)
                }
                views.home()
            }
        })
    }

    function slot1StatusTxt() {
        return slot1Configured ? slotIsConfigured : slotIsEmpty
    }

    function slot2StatusTxt() {
        return slot2Configured ? slotIsConfigured : slotIsEmpty
    }

    function deleteSelectedSlot() {
        yubiKey.erase_slot(views.selectedSlot, function (resp) {
            if (resp.success) {
                views.otpSuccess()
            } else {
                if (resp.error === 'write error') {
                    views.otpWriteError()
                } else {
                    views.otpFailedToConfigureErrorPopup(resp.error)
                }
            }
        })
    }

    function swapConfigurations() {
        yubiKey.swap_slots(function (resp) {
            if (resp.success) {
                views.otpSuccess()
            } else {
                if (resp.error === 'write error') {
                    views.otpWriteError()
                } else {
                    views.otpGeneralError(resp.error)
                }
            }
        })
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    OtpSwapConfigurationsPopup {
        id: otpSwapConfigurationsPopup
        onAccepted: swapConfigurations()
    }

    OtpDeleteSlotPopup {
        id: otpDeleteSlotPopup
        onAccepted: deleteSelectedSlot()
    }

    ColumnLayout {
        visible: !isBusy
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: constants.contentMargins
        Layout.topMargin: constants.contentTopMargin
        Layout.bottomMargin: constants.contentBottomMargin
        Layout.preferredHeight: constants.contentHeight
        Layout.maximumHeight: constants.contentHeight
        Layout.preferredWidth: constants.contentWidth
        Layout.maximumWidth: constants.contentWidth
        spacing: 20
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Heading1 {
                text: qsTr("OTP")
            }

            BreadCrumbRow {
                BreadCrumb {
                    text: qsTr("Home")
                    action: views.home
                }

                BreadCrumbSeparator {
                }

                BreadCrumb {
                    text: qsTr("OTP")
                    active: true
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 50

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Heading2 {
                    text: qsTr("Short Touch (Slot 1)")
                    font.pointSize: constants.h2
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                Label {
                    text: slot1StatusTxt()
                    font.pointSize: constants.h3
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                    spacing: 10
                    Button {
                        text: qsTr("Delete")
                        enabled: slot1Configured
                        onClicked: {
                            views.selectSlot1()
                            otpDeleteSlotPopup.open()
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Permanently delete the configuration of Short Touch (Slot 1)")
                        icon.source: "../images/delete.svg"
                        font.capitalization: Font.MixedCase
                        font.family: constants.fontFamily
                        Material.foreground: yubicoBlue
                        icon.width: 16
                        icon.height: 16
                    }
                    Button {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot1()
                            views.push(otpConfigureSlotView)
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Configure a credential in Short Touch (Slot 1)")
                        icon.source: "../images/wrench.svg"
                        font.capitalization: Font.MixedCase
                        font.family: constants.fontFamily
                        icon.width: 16
                        icon.height: 16
                    }
                }
            }
            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Button {
                    text: qsTr("Swap")
                    enabled: slot1Configured || slot2Configured
                    icon.source: "../images/swap.svg"
                    font.family: constants.fontFamily
                    Material.foreground: yubicoBlue
                    font.capitalization: Font.MixedCase
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: otpSwapConfigurationsPopup.open()
                    flat: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Swap the configurations between the two slots")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Heading2 {
                    id: slot2Heading
                    text: qsTr("Long Touch (Slot 2)")
                    color: slot2Configured ? yubicoBlue : yubicoGrey
                }
                Label {
                    text: slot2StatusTxt()
                    font.pointSize: constants.h3
                    color: slot2Configured ? yubicoBlue : yubicoGrey
                }
                RowLayout {
                    spacing: 10

                    Button {
                        text: qsTr("Delete")
                        enabled: views.slot2Configured
                        onClicked: {
                            views.selectSlot2()
                            otpDeleteSlotPopup.open()
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Permanently delete the configuration of Long Touch (Slot 2)")
                        icon.source: "../images/delete.svg"
                        font.capitalization: Font.MixedCase
                        Material.foreground: yubicoBlue
                        font.family: constants.fontFamily
                        icon.width: 16
                        icon.height: 16
                    }
                    Button {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot2()
                            views.push(otpConfigureSlotView)
                        }
                        font.capitalization: Font.MixedCase
                        font.family: constants.fontFamily
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Configure a credential in Long Touch (Slot 2)")
                        icon.source: "../images/wrench.svg"
                        icon.width: 16
                        icon.height: 16
                    }
                }
            }
        }
    }
}
