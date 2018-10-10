import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: fido2MainView

    property bool hasPin
    property bool pinBlocked
    property string pinMessage
    property int pinRetries
    property bool isBusy

    StackView.onActivating: load()

    objectName: "fido2View"

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
            return qsTr("PIN is blocked")
        }
        if (!hasPin) {
            return qsTr("No PIN is set")
        }
        if (hasPin && pinRetries) {
            return qsTr("A PIN is set, ") + pinRetries + qsTr(" retries left")
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
                text: qsTr("FIDO2")
            }

            BreadCrumbRow {
                items: [
                    { text: qsTr("FIDO2") },
                ]
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60
            id: mainRow

            ColumnLayout {
                Heading2 {
                    text: qsTr("FIDO2 PIN")
                    font.pixelSize: constants.h2
                }
                Label {
                    text: getPinMessage()
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: hasPin ? qsTr("Change PIN") : qsTr("Set PIN")
                    highlighted: true
                    onClicked: hasPin ? views.fido2ChangePin(
                                            ) : views.fido2SetPin()
                    toolTipText: hasPin ? qsTr("Change the FIDO2 PIN") : qsTr(
                                              "Configure a FIDO2 PIN")
                    iconSource: "../images/lock.svg"
                }
            }

            Rectangle {
                id: separator
                Layout.minimumWidth: 1
                Layout.maximumWidth: 1
                Layout.maximumHeight: mainRow.height * 0.7
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yubicoGrey
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("FIDO Reset")
                }
                Label {
                    text: qsTr("Reset all FIDO applications")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: qsTr("Reset")
                    highlighted: true
                    onClicked: views.fido2Reset()
                    toolTipText: qsTr("Reset all FIDO applications")
                    iconSource: "../images/reset.svg"
                }
            }
        }
    }
}
