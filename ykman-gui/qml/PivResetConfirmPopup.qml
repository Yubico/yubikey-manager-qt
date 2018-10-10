import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {

    Heading2 {
        width: parent.width
        text: qsTr("Are you sure you want to reset PIV? This will delete all PIV data, and restore all PINs to the default values.

This action cannot be undone!")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        wrapMode: Text.WordWrap
        Layout.maximumWidth: parent.width
    }
    standardButtons: Dialog.No | Dialog.Yes
}
