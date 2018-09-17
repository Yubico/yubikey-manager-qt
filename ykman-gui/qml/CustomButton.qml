import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

Button {
    id: button

    property string iconSource
    property string toolTipText
    property string foregroundColor: getForegroundColor()

    font.capitalization: Font.MixedCase
    font.family: constants.fontFamily

    ToolTip.text: toolTipText
    ToolTip.delay: 1000
    ToolTip.visible: toolTipText !== '' && hovered

    Material.foreground: foregroundColor

    function getForegroundColor() {
        if (flat && enabled) {
            return yubicoBlue
        } else if (!enabled) {
            return yubicoGrey
        } else if (enabled && highlighted) {
            return yubicoWhite
        } else {
            return yubicoBlue
        }
    }

    contentItem: RowLayout {
        Image {
            visible: iconSource !== null
            id: icon
            fillMode: Image.PreserveAspectFit
            sourceSize.height: 16
            sourceSize.width: 16
            source: iconSource

            ColorOverlay {
                anchors.fill: icon
                source: icon
                color: foregroundColor
            }
        }
        Label {
            text: button.text
            font: button.font
        }
    }
}
