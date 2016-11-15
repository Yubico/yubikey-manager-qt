import QtQuick 2.0

DefaultDialog {

    id: aboutPage
    title: qsTr("About YubiKey Manager")

    Text {
        text: qsTr("YubiKey Manager")
        font.bold: true
    }

    Text {
        text: qsTr("Version: ") + appVersion
    }

    Text {
        text: qsTr("Copyright © 2016, Yubico Inc. All rights reserved.")
    }

    Text {
        text: qsTr("Need help?")
        font.bold: true
    }

    Text {
        text: qsTr("Visit Yubico <a href='https://www.yubico.com/support/knowledge-base/'>Knowledge Base</a>")
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
           anchors.fill: parent
           acceptedButtons: Qt.NoButton
           cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
