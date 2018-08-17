import QtQuick 2.5
import Qt.labs.platform 1.0

MenuBar {

    Menu {
        title: qsTr("\&File")
        MenuItem {
            text: qsTr("E\&xit")
            onTriggered: Qt.quit()
            shortcut: StandardKey.Quit
        }
    }

    Menu {
        title: qsTr("\&Help")
        MenuItem {
            text: qsTr("\&About YubiKey Manager")
            onTriggered: aboutPage.open()
        }
    }
}
