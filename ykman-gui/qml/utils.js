function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", app)
}

function includes(arr, value) {
    return arr.indexOf(value) >= 0;
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
 * Add `objB` into a copy of `objA`.
 *
 * @param objA an object
 * @param objB an object
 *
 * @return a new object containing all key-value pairs in `objA` and `objB`. If
 * a key exists in both `objA` and `objB`, the corresponding value from `objB`
 * is used.
 */
function extend(objA, objB) {
    var copyOfA = Object.keys(objA).reduce(
        function(result, key) {
            result[key] = objA[key];
            return result;
        },
        {}
    );
    return Object.keys(objB).reduce(
        function(result, key) {
            result[key] = objB[key];
            return result;
        },
        copyOfA
    );
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
 * @param arr an array of numbers
 * @return the greatest value in `arr`
 */
function maxIn(arr) {
    return arr.reduce(function(max, next) { return Math.max(max, next) })
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

// Shim for String.prototype.startsWith(), added in Qt 5.8
// Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/startsWith
function startsWith(string, search, pos) {
    return string.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search
}

/**
 * @param arr an Array of numbers
 * @return the sum of the numbers in `arr`
 */
function sum(arr) {
    return arr.reduce(function(sum, next) { return sum + next }, 0)
}
