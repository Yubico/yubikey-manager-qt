import QtQuick 2.9

QtObject {
    readonly property int fido2PinMinLength: 4
    readonly property int fido2PinMaxLength: 128
    readonly property string pivDefaultManagementKey: "010203040506070801020304050607080102030405060708"
    readonly property string pivDefaultPin: "123456"
    readonly property string pivDefaultPuk: "12345678"
    readonly property int pivManagementKeyHexLength: 48
    readonly property int pivPinMinLength: 6
    readonly property int pivPinMaxLength: 8
    readonly property int pivPukMinLength: 6
    readonly property int pivPukMaxLength: 8
    readonly property int h1: 32
    readonly property int h2: 24
    readonly property int h3: 18
    readonly property int h4: 14
    readonly property string fontFamily: "Helvetica Neue"
    readonly property int contentMargins: 40
    readonly property int contentTopMargin: 20
    readonly property int contentBottomMargin: 20
    readonly property int contentWidth: app.width - 80
    readonly property int contentHeight: app.height - header.height - 40
}
