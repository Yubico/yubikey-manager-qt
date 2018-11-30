import QtQuick 2.9
import QtQuick.Layouts 1.3

ColumnLayout {

    property var breadcrumbs
    property string heading: breadcrumbs[breadcrumbs.length - 1]

    Layout.alignment: Qt.AlignLeft | Qt.AlignTop

    Heading1 {
        text: heading
    }

    BreadCrumbRow {
        items: breadcrumbs
    }
}
