import QtQuick 2.5
import QtQuick.Controls 1.4

MenuBar {

    property var enabledFeatures
    property bool enableConnectionsDialog
    property bool enablePgpTouch
    property bool enablePgpPinRetries

    // Feature flag for PIV menu items
    property bool supportForPIV: false

    // Feature flag for OpenPGP menu items
    property bool supportForOATH: false

    // Feature flag for OpenPGP menu items
    property bool supportForOpenPGP: true

    Menu {
        title: qsTr("\&File")
        MenuItem {
            text: qsTr("\&Connections...")
            enabled: enableConnectionsDialog
            onTriggered: connectionsDialog.show()
        }
        MenuSeparator {
        }
        MenuItem {
            text: qsTr("E\&xit")
            onTriggered: Qt.quit()
            shortcut: StandardKey.Quit
        }
    }

    Menu {
        title: qsTr("\&Edit")
        Menu {
            title: qsTr("\&YubiKey Slots")
            enabled: enabledFeatures.indexOf('OTP') !== -1
            MenuItem {
                text: qsTr("\&Configure...")
                onTriggered: slotDialog.start()
            }
            MenuSeparator {
            }
            MenuItem {
                text: qsTr("\&Swap credentials between slots")
                onTriggered: swapSlotsDialog.open()
            }
        }
        Menu {
            title: qsTr("PIV")
            visible: supportForPIV
            enabled: enabledFeatures.indexOf('PIV') !== -1
            MenuItem {
                text: qsTr("Certificates...")
            }
            MenuSeparator {
            }
            MenuItem {
                text: qsTr("Change PIN...")
            }
            MenuItem {
                text: qsTr("Change PUK...")
            }
            MenuItem {
                text: qsTr("Change Management Key...")
            }
            MenuSeparator {
            }
            MenuItem {
                text: qsTr("Reset")
            }
        }
        Menu {
            title: qsTr("OATH")
            enabled: enabledFeatures.indexOf('OATH') !== -1
            visible: supportForOATH
            MenuItem {
                text: qsTr("Reset")
            }
        }
        Menu {
            title: qsTr("OpenPGP")
            enabled: enabledFeatures.indexOf('OPGP') !== -1
            visible: supportForOpenPGP
            MenuItem {
                text: qsTr("Change PIN Retries...")
                onTriggered: openPgpPinRetries.show()
            }
            MenuItem {
                text: qsTr("Change Touch Policy...")
                enabled: enablePgpTouch
                onTriggered: openPgpTouchPolicy.load()
            }
            MenuSeparator {
            }
            MenuItem {
                text: qsTr("Reset")
                onTriggered: openPgpResetDialog.open()
            }
        }
    }

    Menu {
        title: qsTr("\&Help")
        MenuItem {
            text: qsTr("\&About YubiKey Manager")
            onTriggered: aboutPage.show()
        }
    }
}
