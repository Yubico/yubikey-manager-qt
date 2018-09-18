import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.margins: constants.contentMargins
    Layout.topMargin: constants.contentTopMargin
    Layout.bottomMargin: constants.contentBottomMargin
    Layout.preferredHeight: constants.contentHeight
    Layout.maximumHeight: constants.contentHeight
    Layout.preferredWidth: constants.contentWidth
    Layout.maximumWidth: constants.contentWidth
    spacing: 20
}
