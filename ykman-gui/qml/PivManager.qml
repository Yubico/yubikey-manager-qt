import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {

    ChangePinDialog {
        id: changePin
        codeName: 'PIN'

        onCodeChanged: {
            console.log('Change PIN', 'from', currentCode, 'to', newCode)
        }
    }

    function start() {
        changePin.open()
    }

}
