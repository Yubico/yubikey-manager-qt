import QtQuick 2.5
import QtQuick.Controls 1.4
import "utils.js" as Utils

ComboBox {
    property var values

    readonly property var value: values.length > 0 ? values[currentIndex].value : null

    currentIndex: 0
    model: Utils.pick(values, 'text')
}
