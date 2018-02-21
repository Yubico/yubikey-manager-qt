function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
}

/**
 * Wait for `delayMillis` milliseconds, then call `callback`.
 *
 * @param callback a function to call after `delayMillis` milliseconds have passed
 * @param delayMillis the number of milliseconds to wait before calling `callback`
 *
 * @return an object with a function attribute `stop`. The `stop` function takes
 * no arguments, and when called it aborts the delayed execution of the
 * `callback`.
 */
function delay(callback, delayMillis) {
    var timerAlive = true
    var timer = new Timer()
    timer.interval = delayMillis
    timer.repeat = false
    timer.triggered.connect(function () {
        callback()
        if (timerAlive) {
            timerAlive = false
            timer.destroy()
        }
    })
    timer.start()

    return {
        stop: function () {
            if (timerAlive) {
                timerAlive = false
                timer.stop()
                timer.destroy()
            }
        }
    }
}

// Shim for String.prototype.startsWith(), added in Qt 5.8
// Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/startsWith
function startsWith(string, search, pos) {
    return string.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search
}
