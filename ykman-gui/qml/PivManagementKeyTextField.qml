import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

TextField {
    selectByMouse: true
    selectionColor: yubicoGreen
    maximumLength: constants.pivManagementKeyHexLength
    validator: RegExpValidator {
        regExp: /[0-9a-f]*/
    }
    ToolTip.delay: 1000
    ToolTip.visible: hovered
    ToolTip.text: qsTr("Management key must be exactly 48 hexadecimal digits.")
}
