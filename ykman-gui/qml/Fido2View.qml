import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

ColumnLayout {
    id: fido2MainView

    property bool hasPin
    property bool pinBlocked
    property string pinMessage
    property int pinRetries

    Component.onCompleted: load()

    function load() {
        views.setBusy()
        yubiKey.fido_has_pin(function (resp) {
            if (!resp.error) {
                hasPin = resp.hasPin
                if (hasPin) {
                    yubiKey.fido_pin_retries(function (resp) {
                        if (!resp.error) {
                            pinRetries = resp.retries
                        } else {
                            console.log(resp.error)
                            pinBlocked = (resp.error === 'PIN is blocked.')
                        }
                        views.unsetBusy()
                    })
                } else {
                    pinBlocked = false
                    views.unsetBusy()
                }
            } else {
                console.log(resp.error)
                views.unsetBusy()
            }
        })
    }

    function getPinMessage() {
        if (pinBlocked) {
            return qsTr("PIN is blocked.")
        }
        if (!hasPin) {
            return qsTr("No PIN is set.")
        }
        if (hasPin && pinRetries) {
            return qsTr("A PIN is set, ") + pinRetries + qsTr(" retries left.")
        }
    }

    ColumnLayout {
        visible: !isBusy
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Label {
            Layout.fillWidth: true
            color: yubicoBlue
            text: qsTr("FIDO2")
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pointSize: constants.h1
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Label {
                text: getPinMessage()
            }
            Button {
                text: hasPin ? qsTr("Change PIN") : qsTr("Set PIN")
                highlighted: true
                onClicked: hasPin ? views.fido2ChangePin() : views.fido2SetPin()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Label {
                text: qsTr("Reset FIDO.")
            }
            Button {
                text: qsTr("Reset")
                highlighted: true
                onClicked: views.fido2Reset()
            }
        }
    }
}
