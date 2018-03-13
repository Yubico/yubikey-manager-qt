import QtQuick 2.5
import QtQuick.Controls 1.4
import "utils.js" as Utils


/*!
  \brief A <code>ComboBox</code> with pretty labels mapped to well defined values
  \sa ComboBox
*/
ComboBox {
    /*!
      \brief A list of <code>{ text: String, value: any }</code> pairs

      The <code>text</code> attributes will be used as the rendered labels, and
      the <code>value</code> attributes define the possible values of the
      <code>value</code> property.
     */
    property var values

    /*!
      \brief The <code>value</code> attribute of the currently selected item in <code>values</code>
     */
    readonly property var value: values.length > 0 ? values[currentIndex].value : null

    currentIndex: 0
    model: Utils.pick(values, 'text')
}
