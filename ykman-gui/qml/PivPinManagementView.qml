import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    property bool hasPin
    property string pinMessage
    property bool isBusy

    readonly property bool hasProtectedKey: pivData.has_protected_key || false
    readonly property var pivData: yubiKey.piv || {}
    readonly property bool pinBlocked: pinRetries < 1
    readonly property int pinRetries: pivData.pin_tries || 0
    readonly property bool pukBlocked: yubiKey.pivPukBlocked || pivData.puk_blocked || false

    StackView.onActivating: load()

    objectName: "pivPinManagementView"

    function load() {
        isBusy = true
        yubiKey.refreshPivData(function (resp) {
            isBusy = false
            if (!resp.success) {
                pivError.showResponseError(resp)
                views.home()
            }
        })
    }

    function getPinMessage() {
        if (pinBlocked) {
            return qsTr("PIN is blocked.")
        } else {
            return qsTr("%1 retries left").arg(pinRetries)
        }
    }

    function getPukMessage() {
        if (pukBlocked) {
            return qsTr("PUK is blocked.")
        } else {
            return qsTr("PIN Unlock Key")
        }
    }

    function getManagementKeyMessage() {
        if (pivData.has_derived_key) {
            return qsTr("Management key is derived from PIN.")
        } else if (pivData.has_stored_key) {
            if (pinBlocked) {
                return qsTr("Management key is inaccessible because PIN is blocked.")
            } else {
                return qsTr("Management key is stored, protected by PIN.")
            }
        }
        return qsTr("Management key is not stored.")
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
                text: qsTr("Configure PINs")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Configure PINs")
                    }]
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60
            id: mainRow

            ColumnLayout {
                Layout.fillWidth: true

                Heading2 {
                    text: qsTr("PIN")
                    font.pixelSize: constants.h2
                }
                Label {
                    text: getPinMessage()
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: qsTr("Change PIN")
                    highlighted: true
                    onClicked: views.pivChangePin()
                    iconSource: "../images/lock.svg"
                    visible: !pinBlocked
                }
                CustomButton {
                    text: qsTr("Unblock PIN")
                    highlighted: true
                    onClicked: views.pivUnblockPin()
                    toolTipText: qsTr("Unblock PIN")
                    iconSource: "../images/reset.svg"
                    visible: pinBlocked
                    enabled: !pukBlocked
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
                Layout.fillWidth: true

                Heading2 {
                    text: qsTr("PUK")
                    font.pixelSize: constants.h2
                }
                Label {
                    text: getPukMessage()
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                }
                CustomButton {
                    text: qsTr("Change PUK")
                    highlighted: true
                    onClicked: views.pivChangePuk()
                    iconSource: "../images/lock.svg"
                    enabled: !pukBlocked
                }
            }

            Rectangle {
                id: separator2
                Layout.minimumWidth: 1
                Layout.maximumWidth: 1
                Layout.maximumHeight: mainRow.height * 0.7
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yubicoGrey
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true

                Heading2 {
                    text: qsTr("Management Key")
                    font.pixelSize: constants.h2
                }
                Label {
                    text: getManagementKeyMessage()
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    wrapMode: Text.WordWrap
                }
                CustomButton {
                    text: qsTr("Change Management Key")
                    highlighted: true
                    onClicked: views.pivChangeManagementKey()
                    toolTipText: qsTr("Change the PIV management key")
                    iconSource: "../images/lock.svg"
                    enabled: !(hasProtectedKey && pinBlocked)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            BackButton {
            }
        }
    }
}
