import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {

    title: qsTr("Configure FIDO 2")
    minimumHeight: calculatedHeight
    minimumWidth: calculatedWidth
    height: calculatedHeight
    width: calculatedWidth

    property var device
    property bool hasPin
    property int pinRetries
    property int calculatedHeight: calculated().h
    property int calculatedWidth: calculated().w

    function calculated() {
        var stackItem = stack.currentItem
        var doubleMargins = margins * 2
        return {
            w: stackItem ? stackItem.implicitWidth + doubleMargins : 0,
                           h: stackItem ? stackItem.implicitHeight + doubleMargins : 0
        }
    }

    function load() {
        stack.push({
                       item: initial,
                       immediate: true,
                       replace: true
                   })

        function handlePinResp(resp) {
            hasPin = resp
            if (hasPin) {
                device.fido_pin_retries(handleRetriesResp)
            } else {
                show()
            }
        }
        function handleRetriesResp(resp) {
            pinRetries = resp
            show()
        }

        device.fido_has_pin(handlePinResp)
    }

    function getPinMessage() {
        if (hasPin) {
            return qsTr("A PIN is set, ") + pinRetries + qsTr(" retries left.")
        } else {
            return qsTr("No PIN is set.")
        }
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: initial
    }

    Component {
        id: initial
        ColumnLayout {
            Label {
                text: getPinMessage()
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Button {
                    text: qsTr("Cancel")
                    onClicked: close()
                }
                Button {
                    text: qsTr("Reset")
                    onClicked: stack.push({
                                              item: fidoResetDialog,
                                              immediate: true
                                          })
                }
                Button {
                    text: qsTr("Set PIN")
                    onClicked: stack.push({
                                              item: fidoChangePinDialog,
                                              immediate: true
                                          })
                }
            }
        }
    }

    Component {
        id: fidoChangePinDialog
        FidoChangePinDialog {
        }
    }

    Component {
        id: fidoResetDialog
        FidoResetDialog {
        }
    }
}
