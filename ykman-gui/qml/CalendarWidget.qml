import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

ListView {
    id: listview

    snapMode: ListView.SnapOneItem
    orientation: ListView.Horizontal
    highlightMoveDuration: 0
    highlightRangeMode: ListView.StrictlyEnforceRange
    width: 250
    height: 200
    interactive: false
    model: CalendarModel {
        from: new Date()
    }

    signal dateClicked(date date)
    signal goToMonth(date date)

    onGoToMonth: currentIndex = model.indexOf(date)

    delegate: ColumnLayout {
        width: listview.width
        height: listview.height
        Layout.fillWidth: true
        visible: currentIndex === index

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            CustomButton {
                onClicked: listview.decrementCurrentIndex()
                flat: true
                enabled: currentIndex > 0
                iconSource: "../images/back.svg"
            }

            Label {
                text: qsTr("%1 %2").arg(grid.locale.monthName(model.month)).arg(
                          model.year)
                horizontalAlignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            CustomButton {
                onClicked: listview.incrementCurrentIndex()
                flat: true
                iconSource: "../images/next.svg"
            }
        }

        MonthGrid {
            id: grid
            month: model.month
            year: model.year
            locale: Qt.locale('en_US')
            Layout.fillWidth: true

            onClicked: dateClicked(date)
        }
    }
}
