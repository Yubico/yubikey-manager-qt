import QtQml 2.2
import io.thp.pyotherside 1.4


// @disable-check M300
Python {

    onError: handleErrors(traceback)

    Component.onCompleted: {
        importModule('site', function () {
            call('site.addsitedir', [appDir + '/pymodules'], function () {
                addImportPath(urlPrefix + '/py')
                importModule('cli', function () {
                    call('cli.run', [Qt.application.arguments], function (res) {
                        Qt.exit(res)
                    })
                })
            })
        })
    }
    function handleErrors(traceback) {
        if (Utils.includes(traceback, 'KeyboardInterrupt')) {
            Qt.quit()
        } else {
            console.log(traceback)
        }
    }
}
