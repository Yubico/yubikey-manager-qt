# YubiKey Manager GUI

Graphical User Interface for configuring a YubiKey.

NOTE: This project is in BETA. Any part of the application may change before
the next release, and some functionality and documentation is missing at this
point.


## Building for macOS
    qmake ykman-gui.pro -r -spec macx-clang CONFIG+=x86_64
    make
    macdeployqt ykman-gui.app -qmldir=yubikey-manager-gui
    cp -r /Library/Frameworks/Python.framework/Versions/3.4 ykman-gui.app/Contents/Frameworks/Python.framework/Versions/
    add .dylib files to .app bundle
    relink.sh
