import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2
import "slotutils.js" as SlotUtils

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
                if (resp.error_id === 'timeout') {
                    snackbarError.show(qsTr("Failed to load OTP application"))
                } else {
                    snackbarError.showResponseError(resp)
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

    function confirmDelete() {
        confirmationPopup.show(
                    qsTr("Delete slot?"), qsTr(
                        "Do you want to delete the content of %1? This permanently deletes the configuration.").arg(
                        SlotUtils.slotNameCapitalized(views.selectedSlot)),
                    deleteSelectedSlot)
    }


    function deleteSelectedSlot() {
        yubiKey.eraseSlot(views.selectedSlot, function (resp) {
            if (resp.success) {
                load()
                snackbarSuccess.show(qsTr("Configuration deleted"))
            } else {
                if (resp.error_id === 'write error') {
                    views.otpWriteError()
                } else {
                    views.otpFailedToConfigureErrorPopup(resp.error_id)
                }
            }
        })
    }

    function swapConfigurations() {
        yubiKey.swapSlots(function (resp) {
            if (resp.success) {

                load()
                snackbarSuccess.show(
                            qsTr("Configurations swapped between slots"))
            } else {
                if (resp.error_id === 'write error') {
                    snackbarError.show(
                                qsTr("Failed to swap slots. Make sure the YubiKey does not have restricted access."))
                } else if (resp.error_message) {
                    snackbarError.show(resp.error_message)
                } else {
                    snackbarError.show(qsTr("Unknown error."))
                }
            }
        })
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        ViewHeader {
            breadcrumbs: [qsTr("OTP")]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 30

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
                            confirmDelete()
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
                ColumnSeparator {
                    Layout.maximumHeight: parent.height * 0.3
                }
                CustomButton {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: qsTr("Swap")
                    enabled: slot1Configured || slot2Configured
                    iconSource: "../images/swap.svg"
                    onClicked: swapConfigurations()
                    flat: true
                    toolTipText: qsTr("Swap the configurations between the two slots")
                }
                ColumnSeparator {
                    Layout.maximumHeight: parent.height * 0.3
                }
            }

            ColumnLayout {
                Heading2 {
                    id: slot2Heading
                    text: qsTr("Long Touch (Slot 2)")
                    color: slot2Configured ? yubicoBlue : yubicoGrey
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
                            confirmDelete()
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

        ButtonsBar {
        }
    }
}
