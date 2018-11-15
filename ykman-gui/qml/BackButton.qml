CustomButton {
    property var onClickedHandler: function() {
        views.pop()
    }

    text: qsTr("Back")
    onClicked: onClickedHandler()
    iconSource: "../images/back.svg"
}
