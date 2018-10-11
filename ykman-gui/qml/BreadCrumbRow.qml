import QtQuick 2.9
import QtQuick.Layouts 1.2

RowLayout {

    property var items
    property var root: ({
                            text: qsTr("Home")
                        })

    BreadCrumb {
        text: root.text
        action: root.action || (items.length > 0 && function () {
            popToDepth(0)
        })
    }

    Repeater {
        model: items

        RowLayout {
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: items[index].text
                action: items[index].action || (index < items.length - 1
                                                && function () {
                                                    popToDepth(index + 1)
                                                })
                active: !!action
            }
        }
    }
}
