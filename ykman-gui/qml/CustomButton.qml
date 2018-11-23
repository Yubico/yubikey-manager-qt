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
    property bool iconOnRight: false

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

    // Since we are currently targeting Qt 5.9,
    // we can not use the Button.icon property
    // which was introduced in Qt 5.10.
    contentItem: RowLayout {
        Image {
            visible: iconSource !== null && !iconOnRight
            id: iconLeft
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            sourceSize.height: 16
            sourceSize.width: 16
            source: iconSource

            ColorOverlay {
                anchors.fill: iconLeft
                source: iconLeft
                color: foregroundColor
            }
        }
        Label {
            visible: !!button.text
            text: button.text
            font: button.font
        }
        Image {
            visible: iconSource !== null && iconOnRight
            id: iconRight
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            sourceSize.height: 16
            sourceSize.width: 16
            source: iconSource

            ColorOverlay {
                anchors.fill: iconRight
                source: iconRight
                color: foregroundColor
            }
        }
    }
}
