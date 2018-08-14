import QtQuick 2.5
import QtQuick.Controls 2.3

Label {
    property bool active
    property var action
    color: active ? yubicoGrey : yubicoGreen

    MouseArea {
        anchors.fill: parent
        cursorShape: action ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (action) {
                action()
            }
        }
    }
}
