import QtQml 2.2
import io.thp.pyotherside 1.4

Python {
    onError: {
        console.log('Python error: ' + traceback)
    }

    Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('.'))
        importModule('cli', function() {
            call('cli.run', [Qt.application.arguments], Qt.quit)
        })
    }
}
