import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: otpView

    property bool isBusy
    readonly property string slotIsConfigured: qsTr("This slot is configured")
    readonly property string slotIsEmpty: qsTr("This slot is empty")

    StackView.onActivating: load()
    objectName: "otpView"

    function load() {
        isBusy = true
        yubiKey.slotsStatus(function (resp) {
            if (resp.success) {
                views.slot1Configured = resp.status[0]
                views.slot2Configured = resp.status[1]
                views.selectedSlot = 0
                isBusy = false
            } else {
                if (resp.error === 'timeout') {
                    views.otpGeneralError(qsTr(
                                              "Failed to load OTP application"))
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
        yubiKey.eraseSlot(views.selectedSlot, function (resp) {
            if (resp.success) {
                views.otpSuccess()
                load()
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
        yubiKey.swapSlots(function (resp) {
            if (resp.success) {
                views.otpSuccess()
                load()
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

    CustomContentColumn {
        visible: !isBusy
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Heading1 {
                text: qsTr("OTP")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("OTP")
                    }]
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 30
            id: mainRow
            anchors.horizontalCenter: parent.horizontalCenter

            ColumnLayout {
                Heading2 {
                    text: qsTr("Short Touch (Slot 1)")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h2
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                Label {
                    text: slot1StatusTxt()
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spacing: 10
                    CustomButton {
                        text: qsTr("Delete")
                        enabled: slot1Configured
                        onClicked: {
                            views.selectSlot1()
                            otpDeleteSlotPopup.open()
                        }
                        toolTipText: qsTr("Permanently delete the configuration of Short Touch (Slot 1)")
                        iconSource: "../images/delete.svg"
                    }
                    CustomButton {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot1()
                            views.push(otpConfigureSlotView)
                        }
                        toolTipText: qsTr("Configure a credential in Short Touch (Slot 1)")
                        iconSource: "../images/wrench.svg"
                    }
                }
            }

            ColumnLayout {

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Rectangle {
                    Layout.minimumWidth: 1
                    Layout.maximumWidth: 1
                    Layout.maximumHeight: mainRow.height * 0.3
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: qsTr("Swap")
                    enabled: slot1Configured || slot2Configured
                    iconSource: "../images/swap.svg"
                    onClicked: otpSwapConfigurationsPopup.open()
                    flat: true
                    toolTipText: qsTr("Swap the configurations between the two slots")
                }
                Rectangle {
                    Layout.minimumWidth: 1
                    Layout.maximumWidth: 1
                    Layout.maximumHeight: mainRow.height * 0.3
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }

            ColumnLayout {
                Heading2 {
                    id: slot2Heading
                    text: qsTr("Long Touch (Slot 2)")
                    color: slot2configured ? yubicoBlue : yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: slot2StatusTxt()
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    CustomButton {
                        text: qsTr("Delete")
                        enabled: views.slot2Configured
                        onClicked: {
                            views.selectSlot2()
                            otpDeleteSlotPopup.open()
                        }
                        toolTipText: qsTr("Permanently delete the configuration of Long Touch (Slot 2)")
                        iconSource: "../images/delete.svg"
                    }
                    CustomButton {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot2()
                            views.push(otpConfigureSlotView)
                        }
                        toolTipText: qsTr("Configure a credential in Long Touch (Slot 2)")
                        iconSource: "../images/wrench.svg"
                    }
                }
            }
        }
        BackButton {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            flat: true
        }
    }
}
