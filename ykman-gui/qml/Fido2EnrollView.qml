import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    property bool isBusy

    function enroll() {
        isBusy = true
        yubiKey.fidoEnroll(function (resp) {
            if (resp.success) {
                isBusy = false
                snackbarSuccess.show(qsTr("Successfully enrolled fingerprint"))
                views.fido2()
            } else {
                snackbarError.showResponseError(resp)
                views.home()
            }
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
            breadcrumbs: [qsTr("FIDO2")]
        }

        ButtonsBar {
        }
    }
}
