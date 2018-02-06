import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

ColumnLayout {

    property var certificates
    readonly property int numCerts: Object.keys(certificates || {}).length

    Label {
      text: (numCerts === 0
          ? qsTr("You have no certificates loaded.")
          : numCerts === 1
              ? qsTr("You have 1 certificate loaded.")
              : qsTr("You have %1 certificates loaded.").arg(numCerts)
      )
    }

}
