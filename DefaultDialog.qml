import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

ApplicationWindow {
    SystemPalette { id: palette }

    default property alias content: inner_content.data

    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    modality: Qt.ApplicationModal
    color: palette.window
    signal accepted
    signal rejected
    property int margins: 12


    ColumnLayout {
        id: outer_content
        anchors.fill: parent
        anchors.margins: margins

        ColumnLayout {
            id: inner_content
        }
    }

    function resize() {
        var w = 0

        for(var i=0; i<inner_content.visibleChildren.length; i++) {
            w = Math.max(w, inner_content.visibleChildren[i].implicitWidth)
        }
        setWidth(w + 2*outer_content.anchors.margins)
    }
}
