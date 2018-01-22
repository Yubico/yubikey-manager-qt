import QtQuick 2.5
import QtQuick.Controls 1.4

DefaultDialog {

    title: qsTr("Status for OpenPGP")
    property var device
    property var openPgpVersion
    property int pinRetries
    property int resetCodeRetries
    property int adminPinRetries

    Label {
        text: qsTr("OpenPGP")
        font.bold: true
    }

    Label {
        text: qsTr("Version: ") + (openPgpVersion ? openPgpVersion.join('.') : '')
    }

    Label {
        text: qsTr("PIN retries remaining: ") + pinRetries
    }
    Label {
        text: qsTr("Reset Code retries remaining: ") + resetCodeRetries
    }
    Label {
        text: qsTr("Admin PIN retries reamining: ") + adminPinRetries
    }

    function load() {
        device.openpgp_get_version(function (version) {
            openPgpVersion = version
            device.openpgp_get_remaining_pin_retries(function (retries) {
                pinRetries = retries[0]
                resetCodeRetries = retries[1]
                adminPinRetries = retries[2]
                show()
            })
        })
    }
}
