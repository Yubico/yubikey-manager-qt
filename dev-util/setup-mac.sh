# Exit on error
set -e

PY_VERSION="3.6.2"
export MACOSX_DEPLOYMENT_TARGET=10.9
PYOTHERSIDE_VERSION="1.5.3"


install_pyotherside() {
  wget https://github.com/thp/pyotherside/archive/$PYOTHERSIDE_VERSION.tar.gz -P ./lib
  cd lib
  tar -xzvf $PYOTHERSIDE_VERSION.tar.gz
  # Patch PyOtherSide to not be built with debug output
  echo "DEFINES += QT_NO_DEBUG_OUTPUT" >> pyotherside-$PYOTHERSIDE_VERSION/src/src.pro
  cd pyotherside-$PYOTHERSIDE_VERSION
  qmake
  make
  sudo make install
  cd ../../
}


brew update

install_pyotherside

git clone https://github.com/aurelien-rainone/macdeployqtfix.git
brew install qt5 swig ykpers libyubikey hidapi libu2f-host libusb pyenv

# Add qmake to PATH
export PATH="/usr/local/opt/qt/bin:$PATH"

# Build Python 3 with --enable-framework, to be able to distribute it in a .app bundle
brew upgrade pyenv
eval "$(pyenv init -)"
env PYTHON_CONFIGURE_OPTS="--enable-framework CC=clang" pyenv install $PY_VERSION
pyenv global system $PY_VERSION
pip3 install --upgrade pip

# Build and install PyOtherside
cd vendor/pyotherside
qmake
make
sudo make install
cd ../../
qmake
