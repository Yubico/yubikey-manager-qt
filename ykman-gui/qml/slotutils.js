function slotName(slotNumber) {
    if (slotNumber === 1)
        return "short touch"
    if (slotNumber === 2)
        return "long touch"
}

function slotNameCapitalized(slotNumber) {
    if (slotNumber === 1)
        return qsTr("Short Touch (Slot 1)")
    if (slotNumber === 2)
        return qsTr("Long Touch (Slot 2)")
}

function configuredTxt(configured) {
    return configured ? "configured" : "not configured"
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1)
}
