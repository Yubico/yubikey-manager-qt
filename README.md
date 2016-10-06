# YubiKey Manager GUI

Graphical User Interface for configuring a YubiKey.

NOTE: This project is in BETA. Any part of the application may change before
the next release, and some functionality and documentation is missing at this
point.


## Building for macOS
    qmake ykman-gui.pro -r -spec macx-clang CONFIG+=x86_64
    make
    macdeployqt ykman-gui.app -qmldir=yubikey-manager-gui
    Add Python 3 runtime to .app bundle
    Add ykman, click, usb, smartcard to .app bundle
    Add ykman .dylibs to .app bundle
    relink.sh

## Building for Windows
    qmake ykman-gui.pro -r -spec win32-msvc2015
    jom qmake_all
    windeployqtqt ykman-gui.exe -qmldir=yubikey-manager-gui
    Extract python-3.5.2-embed-win32.zip in release directory
    Add ykman, click, usb, smartcard, win32, win32com, win32context to release directory
    Add msvcp140.dll to release directory
    Add ykman .dlls to release directory

### Signing and creating a installer
    signtool.exe sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll ykman-gui.exe
    makensis -D"VERSION=$VERSION" resources/win-installer.nsi
    signtool.exe sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll yubikey-manager-$VERSION-win.exe
