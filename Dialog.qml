import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0

Window {
    SystemPalette { id: palette }

    default property alias content: inner_content.data

    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    modality: Qt.WindowModal
    color: palette.window
    signal accepted
    signal rejected

    readonly property var button_ok: btn_ok
    readonly property var button_cancel: btn_cancel

    ColumnLayout {
        id: outer_content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        ColumnLayout {
            id: inner_content
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                id: btn_ok
                text: qsTr("OK")
                onClicked: function() {
                    close()
                    accepted()
                }
            }
            Button {
                id: btn_cancel
                text: qsTr("Cancel")
                onClicked: function() {
                    close()
                    rejected()
                }
            }
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
