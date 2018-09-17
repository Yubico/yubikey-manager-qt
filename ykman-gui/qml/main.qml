import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.2

ApplicationWindow {
    id: app
    title: qsTr("YubiKey Manager")
    visible: true
    height: 640
    width: 800
    color: yubicoWhite
    readonly property int margins: 12
    readonly property string yubicoGreen: "#9aca3c"
    readonly property string yubicoBlue: "#284c61"
    readonly property string yubicoLightBlue: "#417488"
    readonly property string yubicoGrey: "#939598"
    readonly property string yubicoWhite: "#FFFFFF"

    Component.onDestruction: saveScreenLayout()

    Component.onCompleted: ensureValidWindowPosition()
    Material.primary: yubicoGreen
    Material.accent: yubicoBlue

    header: Header {
        id: header
    }

    function copyToClipboard(value) {
        clipboard.setClipboard(value)
    }

    function enableLogging(logLevel) {
        yubiKey.enableLogging(logLevel, null)
    }

    function enableLoggingToFile(logLevel, logFile) {
        yubiKey.enableLogging(logLevel, logFile)
    }

    function disableLogging() {
        yubiKey.disableLogging()
    }

    function ensureValidWindowPosition() {
        // If we have the same desktop dimensions as last time, use the saved position.
        // If not, put the window in the middle of the screen.
        var savedScreenLayout = (settings.desktopAvailableWidth === Screen.desktopAvailableWidth)
                && (settings.desktopAvailableHeight === Screen.desktopAvailableHeight)
        app.x = (savedScreenLayout) ? settings.x : Screen.width / 2 - app.width / 2
        app.y = (savedScreenLayout) ? settings.y : Screen.height / 2 - app.height / 2
    }

    function saveScreenLayout() {
        settings.desktopAvailableWidth = Screen.desktopAvailableWidth
        settings.desktopAvailableHeight = Screen.desktopAvailableHeight
    }

    function yubiKeyInserted() {
        if (reInsertYubiKey.visible) {
            reInsertYubiKey.close()
            if (views.isConfiguringInterfaces) {
                views.home()
            }
        } else {
            views.home()
        }
    }

    function yubiKeyRemoved() {
        if (!reInsertYubiKey.visible && !views.locked) {
            views.home()
        }
    }

    Constants {
        id: constants
    }

    Settings {
        id: settings
        // Keep track of window and desktop dimensions.
        property alias width: app.width
        property alias height: app.height
        property alias x: app.x
        property alias y: app.y
        property var desktopAvailableWidth
        property var desktopAvailableHeight
    }

    Shortcut {
        sequence: StandardKey.Close
        onActivated: close()
    }

    ClipBoard {
        id: clipboard
    }

    MainMenuBar {
    }

    // @disable-check M301
    YubiKey {
        id: yubiKey
        onError: console.log(traceback)
        onHasDeviceChanged: hasDevice ? yubiKeyInserted() : yubiKeyRemoved()
        onNDevicesChanged: views.home()
    }

    Timer {
        id: poller
        triggeredOnStart: true
        interval: 500
        repeat: true
        running: true
        onTriggered: yubiKey.refresh()
    }

    ContentStack {
        id: views
    }

    ReInsertYubiKeyPopup {
        id: reInsertYubiKey
    }

    TouchYubiKeyPopup {
        id: touchYubiKey
    }

    AboutPagePopup {
        id: aboutPage
    }
}
