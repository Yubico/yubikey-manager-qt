import QtQml 2.2
import io.thp.pyotherside 1.4

Python {
    onError: {
        console.log('Python error: ' + traceback)
    }

    Component.onCompleted: {
        importModule('site', function() {
            call('site.addsitedir', [appDir + '/pymodules'], function() {
                addImportPath(urlPrefix + '/py')
                importModule('cli', function() {
                    call('cli.run', [Qt.application.arguments], Qt.quit)
                })
            })
        })
    }
}
