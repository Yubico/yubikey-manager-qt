import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

ColumnLayout {

    Label {
      text: (0 === 0
          ? qsTr("You have no certificates loaded.")
          : 0 === 1
              ? qsTr("You have 1 certificate loaded.")
              : qsTr("You have %1 certificates loaded.").arg("0")
      )
    }

}
