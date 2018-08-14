import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

Dialog {
    width: app.width - 40
    margins: 20
    modal: true
    closePolicy: Popup.NoAutoClose
    Label {
        width: parent.width
        text: qsTr("Touch your YubiKey!")
        color: yubicoBlue
        font.pointSize: constants.h2
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
}
