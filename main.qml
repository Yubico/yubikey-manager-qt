import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    title: qsTr("YubiKey Manager QML version")

    // @disable-check M301
    YubiKey {
        id: yk
    }
    Timer {
        triggeredOnStart: true
        interval: 1000
        repeat: true
        running: true
        onTriggered: yk.refresh()
    }

    StackLayout {
        anchors.fill: parent
        anchors.margins: 5

        currentIndex: yk.hasDevice ? 1 : 0

        Text {
            text: if (yk.nDevices == 0) {
                      qsTr("No YubiKey detected")
                  } else if (yk.nDevices == 1) {
                      qsTr("Connecting to YubiKey...")
                  } else {
                      qsTr("Multiple YubiKeys detected!")
                  }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        DeviceInfo {
            device: yk
        }
    }
}
