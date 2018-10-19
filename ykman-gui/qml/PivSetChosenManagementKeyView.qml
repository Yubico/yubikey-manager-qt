import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

PivSetManagementKeyView {

    breadcrumbs: [{
                text: qsTr("PIV")
            }, {
                text: qsTr("Configure PINs")
            }, {
                text: qsTr("Management Key Type")
            }, {
                text: qsTr("Separate Management Key")
            }]
    hasNewManagementKeyInput: true
    heading: qsTr("Set Management Key")
    storeManagementKey: false

}
