import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

CustomContentColumn {

    property bool uploadButtonClicked: false

    ColumnLayout {
        Layout.fillHeight: false
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Heading2 {
            text: qsTr("Almost there!")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: constants.h2
            color: yubicoBlue
        }

        Heading2 {
            text: qsTr("The Yubico OTP credential has been configured.")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: constants.h3
            color: yubicoBlue
        }

        CustomButton {
            text: qsTr("Finish upload in browser")
            toolTipText: qsTr("Open an upload form in your default browser")
            onClicked: {
                uploadButtonClicked = true
                Qt.openUrlExternally(uploadUrl)
            }
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            highlighted: true
            iconOnRight: true
            iconSource: "../images/earth.svg"
        }

        Label {
            text: qsTr("If the button doesn't work, use this link:")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.topMargin: constants.contentTopMargin * 2
            font.pixelSize: constants.h4
            color: yubicoGrey
        }

        TextEdit {
            readOnly: true
            selectByMouse: true
            text: uploadUrl
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: constants.h4
            color: yubicoGrey
        }

    }

    ButtonsBar {
        finishCallback: views.otp
        finishEnabled: uploadButtonClicked
        finishText: qsTr("Done")
        finishTooltip: qsTr("Return to the OTP slots view")
    }
}
