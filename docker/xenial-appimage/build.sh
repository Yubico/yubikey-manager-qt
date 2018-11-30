#!/bin/bash

# Exit on error
set -e

# Echo commands
set -x


git clone /sources/yubikey-manager-qt /yubikey-manager-qt

mkdir -p /yubikey-manager-qt/appDir/usr
eval "$(pyenv init -)"
pyenv global 3.6.5
pip3 install -r /yubikey-manager-qt/requirements.txt
cp -R /root/.pyenv/versions/3.6.5/* /yubikey-manager-qt/appDir/usr
dpkg -x /libykpers*.deb /yubikey-manager-qt/appDir/

cd /yubikey-manager-qt

qmake
make
cp ./resources/ykman-gui.desktop appDir/
cp ./resources/icons/ykman.png appDir/
cp ./ykman-gui/ykman-gui appDir/usr/bin/
unset QTDIR
unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH

/linuxdeployqt*.AppImage appDir/usr/bin/ykman-gui -qmldir=./ykman-gui/qml -bundle-non-qt-libs
rm appDir/AppRun
cp ./resources/linux/AppRun appDir/
chmod a+x appDir/AppRun
/appimagetool*.AppImage appDir
