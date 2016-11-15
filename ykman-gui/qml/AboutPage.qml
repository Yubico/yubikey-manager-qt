import QtQuick 2.0

DefaultDialog {

    id: aboutPage
    title: qsTr("About YubiKey Manager")

    Text {
        text:"YubiKey Manager"
        font.bold: true
    }

    Text {
        text: "Version: " + appVersion
    }

    Text {
        text:"Copyright © 2016, Yubico Inc. All rights reserved."
    }

    Text {
        text: "Need help?"
        font.bold: true
    }

    Text {
        text: "Visit Yubico <a href='https://www.yubico.com/support/knowledge-base/'>Knowledge Base</a>"
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
           anchors.fill: parent
           acceptedButtons: Qt.NoButton
           cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
