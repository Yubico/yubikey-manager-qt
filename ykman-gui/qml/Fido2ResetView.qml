import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    readonly property bool hasDevice: yubiKey.hasDevice
    property bool loadedReset
    onHasDeviceChanged: resetOnReInsert()

    function resetOnReInsert() {
        if (!hasDevice && reInsertYubiKey.visible) {
            loadedReset = true
        } else {
            if (loadedReset) {
                loadedReset = false
                touchYubiKey.open()
                yubiKey.fido_reset(function (resp) {
                    touchYubiKey.close()
                    if (resp.success) {
                        fido2SuccessPopup.open()
                    } else {
                        if (resp.error === 'touch timeout') {
                            fido2ResetTouchError.open()
                        } else {
                            fido2GeneralError.error = resp.error
                            fido2GeneralError.open()
                        }
                    }
                })
            }
        }
    }

    TouchYubiKeyPopup {
        id: touchYubiKey
    }

    Fido2ResetConfirmPopup {
        id: fido2ResetConfirmationPopup
        onAccepted: reInsertYubiKey.open()
    }

    Fido2GeneralErrorPopup {
        id: fido2ResetTouchError
        error: qsTr("A reset requires a touch on the YubiKey to be confirmed.")
    }

    Fido2GeneralErrorPopup {
        id: fido2GeneralError
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Reset FIDO")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("FIDO2")
                    }, {
                        text: qsTr("Reset FIDO")
                    }]
            }
        }

        Label {
            color: yubicoBlue
            text: qsTr("This action permanently deletes all FIDO credentials on the device (U2F & FIDO2), and removes the FIDO2 PIN")
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: true
            BackButton {
            }
            CustomButton {
                text: qsTr("Reset")
                highlighted: true
                onClicked: fido2ResetConfirmationPopup.open()
                toolTipText: qsTr("Finish and perform the FIDO Reset")
                iconSource: "../images/finish.svg"
            }
        }
    }
}
