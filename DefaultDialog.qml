import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

Window {
    SystemPalette { id: palette }

    default property alias content: inner_content.data

    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    modality: Qt.ApplicationModal
    color: palette.window
    signal accepted
    signal rejected


    ColumnLayout {
        id: outer_content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        ColumnLayout {
            id: inner_content
        }
    }

    onVisibleChanged: resize()
    onContentChanged: resize()

    function resize() {
        var w = 0
        var h = 0
        for(var i=0; i<contentItem.visibleChildren.length; i++) {
            w = Math.max(w, contentItem.visibleChildren[i].implicitWidth)
            h = Math.max(h, contentItem.visibleChildren[i].implicitHeight)
        }
        width = w + 2*outer_content.anchors.margins
        height = h + 2*outer_content.anchors.margins
    }
}
