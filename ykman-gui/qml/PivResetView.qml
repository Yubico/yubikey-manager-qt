import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property bool isBusy

    function resetPiv() {
        isBusy = true
        yubiKey.pivReset(function (resp) {
            isBusy = false
            if (resp.success) {
                pivSuccessPopup.open()
                views.pop()
            } else {
                pivGeneralError.error = resp.error
                pivGeneralError.open()
            }
        })
    }

    PivResetConfirmPopup {
        id: pivResetConfirmationPopup
        onAccepted: resetPiv()
    }

    PivGeneralErrorPopup {
        id: pivGeneralError
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Reset PIV")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Reset PIV")
                    }]
            }
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

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            CustomButton {
                text: qsTr("Back")
                onClicked: views.pop()
                iconSource: "../images/back.svg"
            }
            CustomButton {
                text: qsTr("Reset")
                highlighted: true
                toolTipText: qsTr("Finish and perform the PIV Reset")
                iconSource: "../images/finish.svg"
                onClicked: pivResetConfirmationPopup.open()
            }
        }
    }
}
