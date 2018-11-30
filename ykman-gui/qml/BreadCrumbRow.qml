import QtQuick 2.9
import QtQuick.Layouts 1.2

RowLayout {

    /**
     * Type: `[item]`, where `item` has the shape:
     *
     * {
     *   text: string,
     *   action: function?,
     * }
     *
     * If `action` is not present, it defaults to popping the stack to the
     * depth of the breadcrumb item. The last breadcrumb item has no action by
     * default.
     */
    property var items

    /**
     * Type: `item` as described in `items` docstring
     */
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
