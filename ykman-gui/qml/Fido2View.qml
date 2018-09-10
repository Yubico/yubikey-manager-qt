import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    id: fido2MainView

    property bool hasPin
    property bool pinBlocked
    property string pinMessage
    property int pinRetries
    property bool isBusy

    Component.onCompleted: load()

    function load() {
        isBusy = true
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
                        isBusy = false
                    })
                } else {
                    pinBlocked = false
                    isBusy = false
                }
            } else {
                console.log(resp.error)
                isBusy = false
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

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    ColumnLayout {
        visible: !isBusy
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("FIDO2")
        }

        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("FIDO2")
                active: true
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 120
            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Heading2 {
                    text: qsTr("FIDO2 PIN")
                    font.pointSize: constants.h2
                }
                Label {
                    text: getPinMessage()
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Button {
                    text: hasPin ? qsTr("Change PIN") : qsTr("Set PIN")
                    highlighted: true
                    onClicked: hasPin ? views.fido2ChangePin(
                                            ) : views.fido2SetPin()
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: hasPin ? qsTr("Change the FIDO2 PIN.") : qsTr(
                                               "Configure a FIDO2 PIN.")
                    icon.source: "../images/lock.svg"
                    icon.width: 16
                    icon.height: 16
                    font.capitalization: Font.MixedCase
                    font.family: constants.fontFamily
                }
            }
            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Heading2 {
                    text: qsTr("FIDO Reset")
                    font.pointSize: constants.h2
                }
                Label {
                    text: qsTr("Reset all FIDO applications.")
                    font.pointSize: constants.h3
                    color: yubicoBlue
                }
                Button {
                    text: qsTr("Reset")
                    highlighted: true
                    onClicked: views.fido2Reset()
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Reset all FIDO applications.")
                    icon.source: "../images/reset.svg"
                    icon.width: 16
                    icon.height: 16
                    font.capitalization: Font.MixedCase
                    font.family: constants.fontFamily
                }
            }
        }
    }
}
