import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4


ColumnLayout {
    property var certificate
    property string description

    readonly property bool hasCertificate: !!certificate
    readonly property string subjectName: hasCertificate ? certificate.subject.commonName : ''
    readonly property string issuerName: hasCertificate ? certificate.subject.commonName : ''
    readonly property string validFrom: hasCertificate ? new Date(certificate.validity.from).toLocaleString() : ''
    readonly property string validTo: hasCertificate ? new Date(certificate.validity.to).toLocaleString() : ''

    Layout.fillWidth: true

    Text {
        text: description
        wrapMode: Text.WordWrap
    }

    GridLayout {
        columns: 4
        Layout.fillWidth: true

        Label {
            text: qsTr("Issued to:")
            Layout.fillWidth: true
        }
        Label {
            text: subjectName
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Issued by:")
            Layout.fillWidth: true
        }
        Label {
            text: issuerName
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Valid from:")
            Layout.fillWidth: true
        }
        Label {
            text: validFrom
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Valid to:")
            Layout.fillWidth: true
        }
        Label {
            text: validTo
            Layout.fillWidth: true
        }
    }

    GridLayout {
        columns: 2
        Layout.fillWidth: true

        Button {
            text: qsTr("Export certificate...")
            enabled: hasCertificate
            Layout.fillWidth: true
        }

        Button {
            Layout.fillWidth: true
            enabled: hasCertificate
            text: qsTr("Delete certificate")
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Import from file...")
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Generate new key...")
        }
    }

}
