import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: pivView

    StackView.onActivating: load()

    objectName: "pivView"

    property bool isBusy

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

    function getNumberOfCertsMessage() {
        var numberOfCerts = yubiKey.numberOfPivCertificates()
        if (numberOfCerts > 0) {
            return numberOfCerts + qsTr(" certificates loaded")
        } else {
            return qsTr("No certificates loaded")
        }
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        RowLayout {
            ColumnLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Heading1 {
                    id: heading
                    text: qsTr("PIV")
                }

                BreadCrumbRow {
                    Layout.fillWidth: true
                    items: [{
                            text: qsTr("PIV")
                        }]
                }
            }
            CustomButton {
                text: qsTr("Setup for macOS")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                highlighted: true
                toolTipText: qsTr("Setup PIV for pairing with macOS")
                flat: true
                iconSource: "../images/mac.svg"
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: mainRow
            spacing: 30

            ColumnLayout {
                Heading2 {
                    text: qsTr("PIN Management")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h2
                }
                Label {
                    text: qsTr("PIN, PUK, Management Key")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Configure PINs")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Configure PIN, PUK and Management Key")
                    iconSource: "../images/lock.svg"
                    onClicked: views.pivPinManagement()
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
                    text: qsTr("Certificates")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: getNumberOfCertsMessage()
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Configure Certificates")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Import, export and generate PIV Certificates")
                    onClicked: views.pivCertificates()
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
                Heading2 {
                    text: qsTr("Reset")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: qsTr("Restore defaults")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                }
                CustomButton {
                    text: qsTr("Reset PIV")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    highlighted: true
                    toolTipText: qsTr("Reset the PIV application")
                    iconSource: "../images/reset.svg"
                    onClicked: views.pivReset()
                }
            }
        }
        BackButton {
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            flat: true
        }
    }
}
