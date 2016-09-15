Deployment macOS:

macdeployqt ykman-gui.app -qmldir=yubikey-manager-gui
cp -r /Library/Frameworks/Python.framework/Versions/3.4 ykman-gui.app/Contents/Frameworks/Python.framework/Versions/
add .dylib files to .app bundle

