import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    visible: true
    title: qsTr("YubiKey Manager")

    menuBar: MainMenuBar {
        enabledFeatures: yk.enabled
        enableConnectionsDialog: yk.connections.length > 1
        enablePgpTouch: supportsOpenPgpTouch()
        enablePgpPinRetries: supportsOpenPgpPinRetries()
    }

    AboutPage {
        id: aboutPage
    }

    Shortcut {
        sequence: StandardKey.Close
        onActivated: close()
    }

    // @disable-check M301
    YubiKey {
        id: yk
        onError: console.log(traceback)
    }

    Timer {
        id: timer
        triggeredOnStart: true
        interval: 500
        repeat: true
        running: true
        onTriggered: yk.refresh()
    }

    Loader {
        id: loader
        sourceComponent: yk.hasDevice ? deviceInfo : message

        anchors.fill: parent
        Layout.minimumWidth: item.Layout.minimumWidth
        Layout.minimumHeight: item.Layout.minimumHeight
    }

    Component {
        id: message
        Text {
            text: if (yk.nDevices == 0) {
                      qsTr("No YubiKey detected.")
                  } else if (yk.nDevices == 1) {
                      qsTr("Connecting to YubiKey...")
                  } else {
                      qsTr("Multiple YubiKeys detected!")
                  }
            Layout.minimumWidth: 370
            Layout.minimumHeight: 360
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
        id: deviceInfo
        DeviceInfo {
            device: yk
        }
    }

    SlotDialog {
        id: slotDialog
        device: yk
    }

    ConnectionsDialog {
        id: connectionsDialog
        device: yk
    }

    SwapSlotDialog {
        id: swapSlotsDialog
        device: yk
    }

    OpenPgpResetDialog {
        id: openPgpResetDialog
        device: yk
    }

    OpenPgpPinRetries {
        id: openPgpPinRetries
        device: yk
    }

    OpenPgpTouchPolicy {
        id: openPgpTouchPolicy
        device: yk
    }

    OpenPgpShowStatus {
        id: openPgpStatus
        device: yk
    }

    MessageDialog {
        id: openPgpResetConfirm
        icon: StandardIcon.Information
        title: qsTr("OpenPGP functionality has been reset.")
        text: qsTr("All data has been cleared and default PINs are set.")
        standardButtons: StandardButton.Ok
    }
    MessageDialog {
        id: confirmSwapped
        icon: StandardIcon.Information
        title: qsTr("Slot credentials swapped")
        text: qsTr("The credentials in the short press and the long press slot has now been swapped.")
        standardButtons: StandardButton.Ok
    }
    MessageDialog {
        id: openPgpTouchConfirm
        icon: StandardIcon.Information
        title: qsTr("Touch Policy for OpenPGP")
        text: qsTr("A new touch policy for OpenPGP has been set.")
        standardButtons: StandardButton.Ok
    }
    MessageDialog {
        id: openPgpPinRetriesConfirm
        icon: StandardIcon.Information
        title: qsTr("Pin retries for OpenPGP")
        text: qsTr("New pin retries for OpenPGP has been set.")
        standardButtons: StandardButton.Ok
    }

    function supportsOpenPgpTouch() {
        // Touch policy for OpenPGP is available from version 4.2.0.
        return parseInt(yk.version.split('.').join('')) >= 420
    }

    function supportsOpenPgpPinRetries() {
        // Note: this only works for YK4. NEOs below 1.0.7 doesn't support this,
        // but since we need to select the applet to get the OpenPGP version,
        // we allow all NEOs to try.
        var version = yk.version.split('.').join('')
        return version < 400 || version > 431
    }

    function clearsPinWhenSettingPinRetries() {
        var version = yk.version.split('.').join('')
        return version < 400
    }

    function enableLogging(logLevel) {
        yk.enableLogging(logLevel, null)
    }
    function enableLoggingToFile(logLevel, logFile) {
        yk.enableLogging(logLevel, logFile)
    }
    function disableLogging() {
        yk.disableLogging()
    }
}
