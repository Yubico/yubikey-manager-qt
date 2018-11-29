import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

RowLayout {

    property bool backButton: true
    property var backCallback: false

    property var nextCallback: false
    property bool nextEnabled: true

    property var finishCallback: false
    property bool finishEnabled: true
    property string finishText: qsTr("Finish")
    property string finishTooltip: ""

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
    Layout.preferredWidth: constants.contentWidth

    BackButton {
        id: nonDefaultBackButton
        flat: true
        onClickedCallback: backCallback
        visible: backCallback
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
    }

    BackButton {
        flat: true
        visible: backButton && !nonDefaultBackButton.visible
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
    }

    NextButton {
        enabled: nextEnabled
        onClicked: nextCallback()
        visible: nextCallback
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
    }

    FinishButton {
        enabled: finishEnabled
        onClicked: finishCallback()
        text: finishText
        toolTipText: finishTooltip
        visible: finishCallback
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
    }

}
