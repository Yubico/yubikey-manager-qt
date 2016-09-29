import QtQuick 2.0
import QtQuick.Dialogs 1.2

MessageDialog {
    icon: StandardIcon.Warning
    title: qsTr("Overwrite existing configuration?")
    text: qsTr("The slot is already configured. Do you want to overwrite the existing configuration? This action cannot be undone.")
    standardButtons: StandardButton.Ok | StandardButton.Cancel
}
