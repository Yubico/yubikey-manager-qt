import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

CustomTextField {

    validator: RegExpValidator {
        regExp: /[0-9a-fA-F]*/
    }

}
