#!/bin/bash

# Exit on error
set -e

# Echo commands
set -x


git clone /sources/yubikey-manager-qt /yubikey-manager-qt
yes | mk-build-deps -i /yubikey-manager-qt/debian/control

cd yubikey-manager-qt
debuild -us -uc

mkdir /deb
mv /yubikey-manager-qt_* /deb

cd /
tar czf yubikey-manager-qt-debian-packages.tar.gz deb

git clone https://github.com/Yubico/yubikey-manager
yes | mk-build-deps -i /yubikey-manager/debian/control

cd yubikey-manager
debuild -us -uc

mv /yubikey-manager_* /python3-yubikey-manager_* /python-yubikey-manager_* /deb
