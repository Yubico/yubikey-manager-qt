import QtQuick 2.9
import QtQuick.Layouts 1.2

RowLayout {

    /**
     * Type: `[item]`, where `item` is a string or an object with the shape:
     *
     * {
     *   text: string,
     *   action: function?,
     * }
     *
     * If `action` is not present, it defaults to popping the stack to the
     * depth of the breadcrumb item. The last breadcrumb item has no action by
     * default.
     *
     * If an `item` is a string, it is equivalent to `{ text: item }`.
     */
    property var items

    /**
     * Type: `item` as described in `items` docstring
     */
    property var root: ({
                            text: qsTr("Home")
                        })

    function getAction(items, index) {
        if (typeof items[index] === 'object' && typeof items[index].action === 'function') {
            return items[index].action
        } else if (index < items.length - 1) {
            return function () { popToDepth(index + 1) }
        }
    }

    function getText(item) {
        if (typeof item === 'string') {
            return item
        } else if (item) {
            return item.text
        }
        return "UNDEFINED"
    }

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
                text: getText(items[index])
                action: getAction(items, index)
                active: !!action
            }
        }
    }
}
