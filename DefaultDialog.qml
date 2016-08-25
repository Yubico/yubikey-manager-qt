import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
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
}
