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
    width: 275
    height: 200

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

            Button {
                onClicked: listview.decrementCurrentIndex()
                enabled: currentIndex > 0
                Material.background: yubicoWhite
                Material.foreground: yubicoBlue

                contentItem: Image {
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: 16
                    sourceSize.width: 16
                    source: "../images/back.svg"
                }
            }

            Label {
                text: qsTr("%1 %2").arg(grid.locale.monthName(model.month)).arg(model.year)
                horizontalAlignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            Button {
                onClicked: listview.incrementCurrentIndex()
                Material.background: yubicoWhite
                Material.foreground: yubicoBlue

                contentItem: Image {
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: 16
                    sourceSize.width: 16
                    source: "../images/next.svg"
                }
            }
        }

        GridLayout {
            columns: 2

            DayOfWeekRow {
                locale: grid.locale

                Layout.column: 1
                Layout.fillWidth: true
            }

            WeekNumberColumn {
                month: grid.month
                year: grid.year
                locale: grid.locale

                Layout.fillHeight: true
            }

            MonthGrid {
                id: grid
                month: model.month
                year: model.year
                Layout.fillWidth: true

                onClicked: dateClicked(date)
            }
        }
    }
}
