import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

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
                                     && currentItem.objectName === "homeview"

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

    function home() {
        clear()
        if (yubiKey.hasDevice) {
            push(homeView)
        } else if (yubiKey.nDevices > 1) {
            push(multipleDevicesView)
        } else {
            push(noDeviceView)
        }
    }

    function configureInterfaces() {
        var interfaceComponent = yubiKey.supportsNewInterfaces(
                    ) ? interfaces : legacyInterfaces
        clear()
        push(interfaceComponent)
    }

    function fido2() {
        clear()
        push(fido2View)
    }

    function fido2SetPin() {
        push(fido2SetPinView)
    }

    function fido2ChangePin() {
        push(fido2ChangePinView)
    }

    function fido2Reset() {
        push(fido2ResetView)
    }

    function otp() {
        clear()
        push(otpViewComponent)
    }

    function otpSuccess() {
        otpSuccessPopup.open()
    }

    function otpWriteError() {
        otpWriteErrorPopup.open()
    }

    function otpFailedToConfigureErrorPopup(error) {
        otpFailedToConfigureErrorPopup.error = error
        otpFailedToConfigureErrorPopup.open()
    }

    function otpGeneralError(error) {
        otpGeneralErrorPopup.error = error
        otpGeneralErrorPopup.open()
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

    OtpWriteErrorPopup {
        id: otpWriteErrorPopup
    }

    OtpFailedToConfigureErrorPopup {
        id: otpFailedToConfigureErrorPopup
    }

    SuccessPopup {
        id: otpSuccessPopup
        onClosed: views.otp()
    }

    SuccessPopup {
        id: fido2SuccessPopup
        onClosed: views.fido2()
    }

    SuccessPopup {
        id: interfacesSuccessPopup
        onClosed: views.home()
    }

    OtpGeneralErrorPopup {
        id: otpGeneralErrorPopup
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
            text: qsTr("Insert your YubiKey!")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
        id: multipleDevicesView
        Heading2 {
            text: qsTr("Make sure only one YubiKey is inserted!")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
