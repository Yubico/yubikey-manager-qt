import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

CustomTextField {
    maximumLength: constants.pivManagementKeyHexLength
    validator: RegExpValidator {
        regExp: /[0-9a-f]*/
    }
    toolTipText: qsTr("Management key must be exactly 48 hexadecimal digits.")
}
