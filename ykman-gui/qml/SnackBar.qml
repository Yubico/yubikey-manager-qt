import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ToolTip {

    property string message: ""

    timeout: 5000
    width: snackLbl.implicitWidth + constants.contentMargins
    height: constants.contentMargins
    x: (app.width - width) / 2
    y: app.height
    bottomMargin: constants.contentMargins / 2
    function show(message) {
        snackLbl.text = message
        open()
    }
    Label {
        id: snackLbl
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: constants.h4
        horizontalAlignment: Qt.AlignHCenter
    }
}
