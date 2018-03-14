import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Dialog {

    property var callback
    property var defaultValue
    property string errorMessage: ''
    property bool hideInput: true
    property string message: qsTr('Please enter the PIN.')

    function ask(cb, errMsg) {
        callback = cb
        errorMessage = errMsg || ''
        reset()
        open()
    }

    title: qsTr('PIN required')

    onAccepted: {
        if (callback) {
            callback(input.text)
        }
        reset()
    }

    onRejected: {
        if (callback) {
            callback(false)
        }
    }

    onReset: input.text = ''

    onVisibleChanged: {
        if (visible) {
            input.focus = true
        }
    }

    ColumnLayout {

        Label {
            text: message
        }

        TextField {
            id: input
            echoMode: hideInput ? TextInput.Password : TextInput.Normal
            focus: true
        }

        Label {
            color: 'red'
            font.italic: true
            text: errorMessage
            visible: errorMessage
        }
    }
}
