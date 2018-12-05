import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

StackView {
    anchors.fill: parent
    initialItem: noDeviceView

    property int selectedSlot
    property bool slot1Configured
    property bool slot2Configured

    property bool locked

    property bool isConfiguringInterfaces: currentItem !== null
                                           && currentItem.objectName === "interfaces"

    property bool isShowingHomeView: currentItem !== null
                                     && currentItem.objectName === "homeView"

    function lock() {
        locked = true
    }

    function unlock() {
        locked = false
    }

    function selectSlot1() {
        selectedSlot = 1
    }

    function selectSlot2() {
        selectedSlot = 2
    }

    function selectedSlotConfigured() {
        if (selectedSlot === 1) {
            return slot1Configured
        }
        if (selectedSlot === 2) {
            return slot2Configured
        }
        return false
    }

    function popToDepth(height) {
        pop(find(function (item, searchIndex) {
            return searchIndex === height
        }))
    }

    function replaceAtDepth(depth, item, newObjectName) {
        var itemToReplace = find(function (item, index) {
            return index === depth
        })
        if (itemToReplace) {
            if (newObjectName) {
                if (itemToReplace.objectName === newObjectName) {
                    pop(itemToReplace)
                } else {
                    replace(itemToReplace, item)
                }
            } else {
                replace(itemToReplace, item)
            }
        } else {
            push(item)
        }
    }

    function home() {
        if (yubiKey.hasDevice) {
            var homeViewOnStack = find(function (item) {
                return item.objectName === 'homeView'
            })
            if (homeViewOnStack) {
                pop(homeViewOnStack)
            } else {
                replaceAtDepth(0, homeView, 'homeView')
            }
        } else if (yubiKey.nDevices > 1) {
            replaceAtDepth(0, multipleDevicesView, 'multipleDevicesView')
        } else {
            replaceAtDepth(0, noDeviceView, 'noDeviceView')
        }
    }

    function configureInterfaces() {
        var interfaceComponent = yubiKey.supportsNewInterfaces(
                    ) ? interfaces : legacyInterfaces
        replaceAtDepth(1, interfaceComponent, 'interfaces')
    }

    function piv() {
        replaceAtDepth(1, pivView, 'pivView')
    }

    function pivCertificates() {
        replaceAtDepth(2, pivCertificatesView, 'pivCertificatesView')
    }

    function pivSetupForMacOs() {
        replaceAtDepth(2, pivSetupForMacOsView, 'pivSetupForMacOs')
    }

    function pivReset() {
        replaceAtDepth(2, pivResetView, 'pivResetView')
    }

    function pivPinManagement() {
        replaceAtDepth(2, pivPinManagementView, 'pivPinManagementView')
    }

    function pivChangePin() {
        replaceAtDepth(3, pivChangePinView, 'pivChangePinView')
    }

    function pivUnblockPin() {
        replaceAtDepth(3, pivUnblockPinView, 'pivUnblockPinView')
    }

    function pivChangePuk() {
        replaceAtDepth(3, pivChangePukView, 'pivChangePukView')
    }

    function pivChangeManagementKey() {
        replaceAtDepth(3, pivChangeManagementKeyView,
                       'pivChangeManagementKeyView')
    }

    function pivGetPinOrManagementKey(pinCallback, keyCallback) {
        if ((yubiKey.piv || {

             }).has_protected_key) {
            pivPinPopup.getPinAndThen(pinCallback)
        } else {
            pivManagementKeyPopup.getKeyAndThen(keyCallback)
        }
    }

    function fido2() {
        replaceAtDepth(1, fido2View, 'fido2View')
    }

    function fido2SetPin() {
        replaceAtDepth(2, fido2SetPinView, 'fido2SetPinView')
    }

    function fido2ChangePin() {
        replaceAtDepth(2, fido2ChangePinView, 'fido2ChangePinView')
    }

    function fido2Reset() {
        replaceAtDepth(2, fido2ResetView, 'fido2ResetView')
    }

    function otp() {
        replaceAtDepth(1, otpViewComponent, 'otpView')
    }

    function otpConfirmOverwrite(callback) {
        confirmationPopup.show(
                    [qsTr("%1 is already configured.").arg(
                         SlotUtils.slotNameCapitalized(
                             views.selectedSlot)), qsTr(
                         "Do you want to overwrite the existing configuration?")],
                    callback)
    }

    function otpWriteError() {
        snackbarError.show(
                    [qsTr("Failed to modify %1.").arg(
                         SlotUtils.slotNameCapitalized(
                             views.selectedSlot)), qsTr(
                         "Make sure the YubiKey does not have restricted access.")])
    }

    function otpFailedToConfigureErrorPopup(error) {
        snackbarError.show(qsTr("Failed to configure %1. %2").arg(
                               SlotUtils.slotNameCapitalized(
                                   views.selectedSlot)).arg(error))
    }

    Component {
        id: fido2SetPinView
        Fido2SetPinView {
        }
    }

    Component {
        id: fido2ChangePinView
        Fido2ChangePinView {
        }
    }

    Component {
        id: fido2ResetView
        Fido2ResetView {
        }
    }

    Component {
        id: homeView
        HomeView {
        }
    }

    Component {
        id: otpViewComponent
        OtpView {
        }
    }

    Component {
        id: otpConfigureSlotView
        OtpConfigureSlotView {
        }
    }

    Component {
        id: otpYubiOtpView
        OtpYubiOtpView {
        }
    }

    Component {
        id: otpChalRespView
        OtpChalRespView {
        }
    }
    Component {
        id: otpOathHotpView
        OtpOathHotpView {
        }
    }
    Component {
        id: otpStaticPasswordView
        OtpStaticPasswordView {
        }
    }

    Component {
        id: fido2View
        Fido2View {
        }
    }

    Component {
        id: pivView

        PivView {
        }
    }

    Component {
        id: pivCertificatesView
        PivCertificateView {
        }
    }

    Component {
        id: pivSetupForMacOsView
        PivSetupForMacOsView {
        }
    }

    Component {
        id: pivResetView
        PivResetView {
        }
    }

    Component {
        id: pivPinManagementView

        PivPinManagementView {
        }
    }

    Component {
        id: pivChangePinView

        PivChangePinView {
        }
    }

    Component {
        id: pivUnblockPinView

        PivUnblockPinView {
        }
    }

    Component {
        id: pivChangePukView

        PivChangePukView {
        }
    }

    Component {
        id: pivChangeManagementKeyView

        PivSetManagementKeyView {
        }
    }

    Component {
        id: pivGenerateCertificateWizard

        PivGenerateCertificateWizard {
        }
    }

    Component {
        id: legacyInterfaces
        LegacyInterfaceView {
        }
    }

    Component {
        id: interfaces
        InterfaceView {
        }
    }

    Component {
        id: noDeviceView
        Heading2 {
            text: qsTr("Insert your YubiKey")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
        id: multipleDevicesView
        Heading2 {
            text: qsTr("Make sure only one YubiKey is inserted")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ConfirmationPopup {
        id: confirmationPopup
    }

    PivPinPopup {
        id: pivPinPopup
    }

    PivManagementKeyPopup {
        id: pivManagementKeyPopup
    }

    PivPasswordPopup {
        id: pivPasswordPopup
    }

    SnackBarSuccess {
        id: snackbarSuccess
    }

    SnackBarError {
        id: snackbarError
    }
}
