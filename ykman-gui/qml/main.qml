import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: root

    visible: true
    title: qsTr("YubiKey Manager")

    menuBar: MainMenuBar {
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
        running: !slotDialog.visible && !connectionsDialog.visible
                 && !pivManager.visible
        onTriggered: yk.refresh()
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent
        Layout.fillWidth: true
        Header {
        }
        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: yk.hasDevice ? deviceInfo : message
            Layout.minimumWidth: item.Layout.minimumWidth
            Layout.minimumHeight: item.Layout.minimumHeight
        }
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

    PivManager {
        id: pivManager
        device: yk
    }

    ConnectionsDialog {
        id: connectionsDialog
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

    FidoDialog {
        id: fidoDialog
        device: yk
    }

    TouchYubiKey {
        id: touchYubiKeyPrompt
    }

    MessageDialog {
        id: openPgpResetConfirm
        icon: StandardIcon.Information
        title: qsTr("OpenPGP functionality has been reset.")
        text: qsTr("All data has been cleared and default PINs are set.")
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

    ClipBoard {
        id: clipboard
    }

    function copyToClipboard(value) {
        clipboard.setClipboard(value)
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
