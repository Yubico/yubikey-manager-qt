import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2
import "utils.js" as Utils

ColumnLayout {

    readonly property string authenticationName: 'Yubico PIV Authentication'
    readonly property string encryptionName: 'Yubico PIV Encryption'
    readonly property string algoritm: 'ECCP256'
    property string expirationDate: Utils.formatDate(
                                        getExpirationDateIn30years())
    property bool isBusy

    function getExpirationDateIn30years() {
        var date = new Date()
        date.setFullYear(date.getFullYear() + 30)
        return date
    }

    function setupForMacOs(confirmedOverwrite) {
        function _prompt_for_pin_and_key(pin, key) {
            if (key) {
                pivPinPopup.getPinAndThen(function (pin) {
                    _finish(pin, key)
                })
            } else {
                views.pivGetPinOrManagementKey(function (pin) {
                    _finish(pin, false)
                }, function (key) {
                    _prompt_for_pin_and_key(false, key)
                })
            }
        }

        function _finish(pin, managementKey) {
            isBusy = true

            function _generateCertificate(slot, cb) {
                yubiKey.pivGenerateCertificate({
                                                   slotName: slot,
                                                   algorithm: algoritm,
                                                   commonName: authenticationName,
                                                   expirationDate: expirationDate,
                                                   selfSign: true,
                                                   pin: pin,
                                                   keyHex: managementKey,
                                                   callback: cb
                                               })
            }

            _generateCertificate('AUTHENTICATION', function (resp) {
                if (resp.success) {
                    _generateCertificate('KEY_MANAGEMENT', function (resp) {
                        if (resp.success) {
                            successPopup.show(
                                        "Remove and re-insert your YubiKey to start the macOS pairing setup.")
                            views.pop()
                        } else {
                            pivError.showResponseError(resp)
                        }
                        isBusy = false
                    })
                } else {
                    isBusy = false
                    pivError.showResponseError(resp)
                }
            })
        }

        if (confirmedOverwrite || (!yubiKey.pivCerts['AUTHENTICATION']
                                   && !yubiKey.pivCerts['KEY_MANAGEMENT'])) {
            _prompt_for_pin_and_key()
        } else {
            confirmationPopup.show(
                        [qsTr("This will overwrite any existing key and certificate in slot 9a and 9d."), qsTr(
                             "This action cannot be undone!"), qsTr(
                             'Are you sure you want to continue?')],
                        function () {
                            setupForMacOs(true)
                        })
        }
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
                text: qsTr("Setup for macOS")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Setup for macOS")
                    }]
            }
        }

        Label {
            color: yubicoBlue
            text: qsTr("This version of macOS allows you to pair a YubiKey with your user account. When you have completed the pairing, you can use your YubiKey to login to macOS.")
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
        }

        ButtonsBar {
            finishCallback: setupForMacOs
            finishText: qsTr("Setup for macOS")
            finishTooltip: qsTr("Finish and setup for macOS")
        }
    }
}
