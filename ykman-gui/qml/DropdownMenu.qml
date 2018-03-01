import QtQuick 2.5
import QtQuick.Controls 1.4
import "utils.js" as Utils


ComboBox {
    property var values

    readonly property var value: values[currentIndex].value

    currentIndex: 0
    model: Utils.pick(values, 'text')
}
