import QtQuick 2.9
import QtQuick.Controls 2.2

Label {
    property bool active
    property var action
    color: action ? yubicoGreen : yubicoGrey
    font.underline: !active && action && mouseArea.containsMouse
    font.pixelSize: constants.h4

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
