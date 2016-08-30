import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

ColumnLayout {

    property var device
    property var slotsEnabled: [false, false]
    property int selectedSlot
    signal configureSlot(int slot)
    signal updateStatus
    signal goToOverview
    signal goToSelectType
    signal goToSlotStatus

    Text {
        textFormat: Text.StyledText
        text: "<h2>Configure YubiKey OTP</h2><br/><p>When triggered, the YubiKey will output a one time password.</p>"
    }

    GridLayout {
        columns: 3
        Text {
            text: qsTr("Public ID")
        }
        TextField {
            id: publicIdLbl
            implicitWidth: 110
            font.family: "Courier"
        }
        CheckBox {
            anchors.margins: 5
            anchors.left: publicIdLbl.right
            text: qsTr("Use serial number")
        }
        Text {
            text: qsTr("Private ID")
        }
        TextField {
            id: privateIdLbl
            implicitWidth: 110
            font.family: "Courier"
        }
        Button {
            anchors.margins: 5
            text: qsTr("Generate")
            anchors.left: privateIdLbl.right
        }
        Text {
            text: qsTr("Secret key")
        }
        TextField {
            id: secretKeyLbl
            implicitWidth: 260
            font.family: "Courier"
        }
        Button {
            anchors.margins: 5
            anchors.left: secretKeyLbl.right
            text: qsTr("Generate")
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: qsTr("Back")
            onClicked: goToSelectType()
        }
        Button {
            text: qsTr("Finish")
        }
    }
}
