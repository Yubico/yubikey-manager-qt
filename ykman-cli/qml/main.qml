import QtQml 2.2
import io.thp.pyotherside 1.4


// @disable-check M300
Python {

    onError: handleErrors(traceback)

    Component.onCompleted: {
        var path = appDir
        if (Qt.platform.os === "osx") {
            path = path + '/../Resources/pymodules'
        } else {
            path = path + '/pymodules'
        }

        importModule('site', function () {
            call('site.addsitedir', [path], function () {
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
        if (traceback.indexOf('KeyboardInterrupt') >= 0) {
            Qt.quit()
        } else {
            console.log(traceback)
        }
    }
}
