import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: header
    spacing: 0
    height: 48
    Layout.maximumHeight: 48
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Rectangle {
        id: background
        Layout.minimumHeight: 45
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#ffffff"
        Image {
            id: logo
            width: 100
            height: 28
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottomMargin: 5
            anchors.bottom: parent.bottom
            source: "../images/yubico-logo.svg"
        }
        Label {
            text: qsTr("<a href='https://www.yubico.com/kb' style='color:#284c61;text-decoration:none'>help</a>")
            textFormat: Text.RichText
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottomMargin: 5
            anchors.bottom: parent.bottom
            onLinkActivated: Qt.openUrlExternally(link)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
    Rectangle {
        id: headerBorder
        Layout.minimumHeight: 3
        Layout.maximumHeight: 3
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#9aca3c"
    }
}
