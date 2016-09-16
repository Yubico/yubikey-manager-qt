import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

DefaultDialog {

    title: qsTr("Configure YubiKey slots")

    property var device
    property var slotsEnabled: [false, false]
    property bool hasDevice: device ? device.hasDevice : false
    property int selectedSlot
    minimumWidth: 300

    onHasDeviceChanged: close()

        Loader {
            id: loader
            source: "SlotOverview.qml"
            Layout.fillWidth: true
            onLoaded: {
                deviceBinder.target = loader.item
                selectedSlotBinder.target = loader.item
                slotStatusBinder.target = loader.item
                resize()
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

        function updateStatus() {
            device.slots_status(function (res) {
                slotsEnabled = res
            })
        }

        function start() {
            loader.source = "SlotOverview.qml"
            device.slots_status(function (res) {
                slotDialog.slotsEnabled = res
                show()
            })
        }

}
