import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    readonly property bool pinBlocked: yubiKey.piv.pin_tries < 1

    function next() {
        if (storedBtn.checked) {
            console.log('Stored management key')
        } else {
            console.log('Separate management key')
        }
    }

    CustomContentColumn {

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Heading1 {
                text: qsTr("Select Management Key Type")
            }

            BreadCrumbRow {
                items: [{
                        text: qsTr("PIV")
                    }, {
                        text: qsTr("Configure PINs")
                    }, {
                        text: qsTr("Management Key Type")
                    }]
            }
        }

        ButtonGroup {
            id: configViewOptions
            buttons: typeColumn.children
        }

        GridLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            id: typeColumn
            Layout.fillWidth: true
            Layout.leftMargin: 20
            columns: 2


            RadioButton {
                id: storedBtn
                text: qsTr("PIN as management key")
                checked: !pinBlocked
                font.pixelSize: constants.h3
                Material.foreground: yubicoBlue
                enabled: !pinBlocked
            }

            Label {
                text: pinBlocked ? qsTr("PIN is blocked.") : qsTr("A random management key will be stored on the YubiKey, protected by the PIN. Recommended for most users.")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RadioButton {
                id: separateBtn
                text: qsTr("Separate management key")
                checked: pinBlocked
                font.pixelSize: constants.h3
                Material.foreground: yubicoBlue
            }

            Label {
                text: qsTr("Input or generate a new management key, which will not be stored and must be provided to change most settings. Enables an administrator other than the user to change settings.")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            CustomButton {
                id: backBtn
                text: qsTr("Back")
                onClicked: views.pop()
                iconSource: "../images/back.svg"
            }
            CustomButton {
                id: nextBtn
                text: qsTr("Next")
                highlighted: true
                onClicked: next()
                iconSource: "../images/next.svg"
            }
        }
    }
}
