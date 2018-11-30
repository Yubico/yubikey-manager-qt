import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property bool isBusy

    function resetPiv() {
        confirmationPopup.show(
                    [qsTr("Are you sure you want to reset PIV? This will delete all PIV data, and restore all PINs to the default values."), qsTr(
                         "This action cannot be undone!")], function () {
                             isBusy = true
                             yubiKey.pivReset(function (resp) {
                                 isBusy = false
                                 if (resp.success) {
                                     successPopup.open()
                                     views.pop()
                                 } else {
                                     errorPopup.showResponseError(resp)
                                 }
                             })
                         })
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        ViewHeader {
            heading: qsTr("Reset PIV")
            breadcrumbs: [qsTr("PIV"), qsTr("Reset PIV")]
        }

        Label {
            color: yubicoBlue
            text: qsTr("This action permanently deletes all PIV data and restores all PINs to the default values.")
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
        }

        ButtonsBar {
            finishCallback: resetPiv
            finishText: qsTr("Reset")
            finishTooltip: qsTr("Finish and perform the PIV Reset")
        }
    }
}
