CustomButton {
    property var onClickedCallback: function () {
        views.pop()
    }

    text: qsTr("Back")
    onClicked: onClickedCallback()
    iconSource: "../images/back.svg"
}
