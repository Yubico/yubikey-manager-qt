import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

TextField {
    background.width: width // Workaround for QTBUG-71875, drop if fixed in all supported versions.
    selectByMouse: true
    selectionColor: yubicoGreen
}
