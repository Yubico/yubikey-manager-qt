import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

CustomContentColumn {

    Heading2 {
        text: qsTr("Almost there!")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        font.pixelSize: constants.h2
        color: yubicoBlue
    }

    Heading2 {
        text: qsTr("Please finish the upload in your browser.")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        font.pixelSize: constants.h2
        color: yubicoBlue
    }

    Label {
        text: qsTr("If your browser did not open automatically, use this link:")
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        font.pixelSize: constants.h3
        color: yubicoGrey
    }

    TextEdit {
        readOnly: true
        selectByMouse: true
        textFormat: Text.RichText
        text: "<a href=\"" + uploadUrl + "\">" + uploadUrl + "</a>"
        onLinkActivated: Qt.openUrlExternally(link)
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        font.pixelSize: constants.h3
        color: yubicoGrey
    }

    ButtonsBar {
        finishCallback: views.otp
        finishText: qsTr("Done")
        finishTooltip: qsTr("Return to the OTP slots view")
    }
}
