import QtQuick 2.9
import QtQuick.Layouts 1.2

RowLayout {

    property var items
    property var root: ({
                            text: qsTr("Home"),
                            action: views.home
                        })

    BreadCrumb {
        text: root.text
        action: root.action
    }

    Repeater {
        model: items

        RowLayout {
            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: items[index].text
                action: items[index].action
                active: index == items.length - 1
            }
        }
    }
}
