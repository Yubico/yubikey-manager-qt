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
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
chmod a+x appimagetool*.AppImage
unset QTDIR
unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH

./linuxdeployqt*.AppImage appDir/usr/bin/ykman-gui -qmldir=./ykman-gui/qml -bundle-non-qt-libs
rm appDir/AppRun
cp ./resources/linux/AppRun appDir/
chmod a+x appDir/AppRun
./appimagetool*.AppImage appDir
