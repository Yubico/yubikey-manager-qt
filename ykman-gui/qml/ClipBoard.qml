import QtQuick 2.9

TextEdit {
    visible: false
    function setClipboard(value) {
        text = value
        selectAll()
        copy()
    }
}
