import QtQuick 2.5
import QtQuick.Controls 1.4

DefaultDialog {

    id: aboutPage
    title: qsTr("About YubiKey Manager")

    Label {
        text: qsTr("YubiKey Manager")
        font.bold: true
    }

    Label {
        text: qsTr("Version: ") + appVersion
    }

    Label {
        text: qsTr("Copyright © 2018, Yubico Inc. All rights reserved.")
    }

    Label {
        text: qsTr("Need help?")
        font.bold: true
    }

    Label {
        text: qsTr("Visit Yubico <a href='https://www.yubico.com/support/knowledge-base/'>Knowledge Base</a>")
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
