import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("Configure YubiKey Slots")

    property var device
    property var slotsEnabled: [false, false]
    property bool hasDevice: device ? device.hasDevice : false
    property int selectedSlot
    signal goToOverview
    minimumWidth: 500

    onHasDeviceChanged: close()
    onGoToOverview: loader.source = "SlotOverview.qml"

    onVisibleChanged: {
        if (visible) {
            resize()
        } else {
            loader.source = "SlotOverview.qml"
        }
    }

    Loader {
        id: loader
        source: "SlotOverview.qml"
        Layout.fillWidth: true
        onLoaded: {
            deviceBinder.target = loader.item
            selectedSlotBinder.target = loader.item
            slotStatusBinder.target = loader.item
        }
    }

    Binding {
        id: deviceBinder
        property: "device"
        value: device
    }

    Binding {
        id: slotStatusBinder
        property: "slotsEnabled"
        value: slotsEnabled
    }

    Binding {
        id: selectedSlotBinder
        property: "selectedSlot"
        value: selectedSlot
    }

    Connections {
        target: loader.item
         onConfigureSlot: {
             selectedSlot = slot
             loader.source = "SlotStatus.qml"
         }
         onUpdateStatus: updateStatus()
         onGoToOverview: loader.source = "SlotOverview.qml"
         onGoToSlotStatus: loader.source = "SlotStatus.qml"
         onGoToSelectType: loader.source = "SlotSelectType.qml"
         onGoToConfigureOTP: loader.source = "SlotConfigureOTP.qml"
         onGoToChallengeResponse: loader.source = "SlotConfigureChallengeResponse.qml"
         onGoToStaticPassword: loader.source = "SlotConfigureStaticPassword.qml"
         onGoToOathHotp: loader.source = "SlotConfigureOathHotp.qml"
     }

    MessageDialog {
        id: confirmConfigured
        icon: StandardIcon.Information
        title: "Slot configured"
        text: "The slot is now configured."
        standardButtons: StandardButton.Ok
        onAccepted: {
            goToOverview()
        }
    }

    MessageDialog {
        id: writeError
        icon: StandardIcon.Critical
        title: "Error writing to  slot"
        text: "Failed to write to the slot. Make sure the YubiKey does not have restricted access."
        standardButtons: StandardButton.Ok
    }

    function updateStatus() {
        device.slots_status(function (res) {
            slotsEnabled = res
        })
    }

    function reInit() {
        loader.source = "SlotOverview.qml"
    }

    function start() {
        device.slots_status(function (res) {
            slotDialog.slotsEnabled = res
            show()
        })
    }
}
