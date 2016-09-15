#!/bin/bash

INT="install_name_tool"
ID="$INT -id"
CHANGE="$INT -change"

BASE="@executable_path/../Frameworks"

`$ID $BASE/libhidapi.dylib libhidapi.dylib`
`$ID $BASE/libjson-c.dylib libjson-c.dylib`
`$ID $BASE/libjson.dylib libjson.dylib`
`$ID $BASE/libu2f-host.dylib libu2f-host.dylib`
`$ID $BASE/libusb-1.0.dylib libusb-1.0.dylib`
`$ID $BASE/libykpers-1.dylib libykpers-1.dylib`
`$ID $BASE/libyubikey.dylib libyubikey.dylib`

`$CHANGE @executable_path/../lib/libjson-c.2.dylib $BASE/libjson-c.dylib libjson.dylib`
`$CHANGE @executable_path/../lib/libhidapi.0.dylib $BASE/libhidapi.dylib libu2f-host.dylib`
`$CHANGE @executable_path/../lib/libjson-c.2.dylib $BASE/libjson-c.dylib libu2f-host.dylib`
`$CHANGE @executable_path/../lib/libyubikey.0.dylib $BASE/libyubikey.dylib libykpers-1.dylib`
`$CHANGE @executable_path/../lib/libjson-c.2.dylib $BASE/libjson-c.dylib libykpers-1.dylib`
