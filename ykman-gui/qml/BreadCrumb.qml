import QtQuick 2.5
import QtQuick.Controls 2.3

Label {
    property bool active
    property var action
    color: active ? yubicoGrey : yubicoGreen
    font.underline: !active && mouseArea.containsMouse

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: action ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (action) {
                action()
            }
        }
        hoverEnabled: true
    }
}
