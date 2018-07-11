import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

Popup {
    width: app.width - 40
    margins: 20
    modal: true
    closePolicy: Popup.NoAutoClose
    ColumnLayout {
        anchors.fill: parent
        Label {
            text: qsTr('Touch your YubiKey!')
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            color: yubicoBlue
            font.pointSize: constants.h2
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
    }
}
