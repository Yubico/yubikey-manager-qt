CustomButton {
    property var onClickedCallback

    text: qsTr("Back")
    onClicked: {
        if (onClickedCallback) {
            onClickedCallback()
        } else {
            views.pop()
        }
    }
    iconSource: "../images/back.svg"
}
