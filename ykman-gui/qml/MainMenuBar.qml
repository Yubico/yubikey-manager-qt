import QtQuick 2.5
import QtQuick.Controls 1.4

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
            onTriggered: aboutPage.show()
        }
    }
}
