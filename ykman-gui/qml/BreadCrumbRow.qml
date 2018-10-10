import QtQuick 2.9
import QtQuick.Layouts 1.2

RowLayout {

    property var items
    property var root: ({ text: qsTr("Home") })

    BreadCrumb {
        text: root.text
        action: items.length > 0 && function() { popToHeight(0) }
    }

    Repeater {
        model: items

        RowLayout {
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: items[index].text
                action: !active && function() {
                    popToHeight(index + 1)
                }
                active: index === items.length - 1
            }
        }
    }
}
