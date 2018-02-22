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

/**
 * @param lst a QML basic type `list` value
 * @return the `lst` converted to a JavaScript Array value
 */
function listToArray(lst) {
    var result = []
    for (var i = 0; i < lst.length; ++i) {
        result.push(lst[i])
    }
    return result
}

/**
 * @param arr an Array of numbers
 * @return the sum of the numbers in `arr`
 */
function sum(arr) {
    return arr.reduce(function(sum, next) { return sum + next }, 0)
}

/**
 * @param arr an Array or QML list of objects
 * @param name a String containing a property name
 * @return `arr.map(function(item) { return item[name] })`
 */
function pick(arr, name) {
    if (arr instanceof Array) {
        return arr.map(function(item) { return item[name] })
    } else {
        return pick(listToArray(arr), name)
    }
}
