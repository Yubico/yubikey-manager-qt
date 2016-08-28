import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ApplicationWindow {
    visible: true
    title: qsTr("YubiKey Manager")
    minimumHeight: 300
    minimumWidth: 300

    // @disable-check M301
    YubiKey {
        id: yk
    }
    Timer {
        id: timer
        triggeredOnStart: true
        interval: 1000
        repeat: true
        running: active
        onTriggered: yk.refresh()
    }

    Loader {
        anchors.fill: parent
        anchors.margins: 5
        sourceComponent: yk.hasDevice ? deviceInfo : message
    }

    Component {
        id: message
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
    }

    Component {
        id: deviceInfo
        DeviceInfo {
            device: yk
        }
    }
}
