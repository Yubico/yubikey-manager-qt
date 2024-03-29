FROM ubuntu:bionic
RUN apt-get update -qq \
    && apt-get install -qq software-properties-common \
    && add-apt-repository -y ppa:beineri/opt-qt-5.14.2-bionic \
    && apt-get -qq update \
    && apt-get -qq upgrade
RUN apt-get install -y git make build-essential libssl-dev zlib1g-dev libbz2-dev \
    devscripts equivs python3-dev python3-pip python3-venv wget fuse \
    qt514base qt514declarative qt514xmlpatterns qt514script qt514tools qt514multimedia \
    qt514svg qt514graphicaleffects qt514imageformats qt514translations qt514quickcontrols \
    qt514sensors qt514serialbus qt514serialport qt514x11extras qt514quickcontrols2 \
    qt514connectivity qt514scxml qt514wayland qt514remoteobjects qtbase5-dev \
    desktop-file-utils libglib2.0-bin qtchooser python3-pip python mesa-common-dev curl swig \
    libpcsclite-dev libffi-dev
ENV QT_BASE_DIR=/opt/qt514 \
    QT_DIR=/opt/qt514 \
    PYTHON_CFLAGS=-fPIC \
    PYTHON_CONFIGURE_OPTS=--enable-shared
ENV LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/root/.pyenv/bin:$QT_BASE_DIR/bin:$PATH
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && eval "$(pyenv init --path)" \
    && pyenv update \
    && pyenv install --force 3.11.1 \
    && pyenv global 3.11.1 \
    && wget https://github.com/thp/pyotherside/archive/1.5.9.tar.gz \
    && tar -xzvf 1.5.9.tar.gz \
    && echo "DEFINES += QT_NO_DEBUG_OUTPUT" >> pyotherside-1.5.9/src/src.pro \
    && cd pyotherside-1.5.9/src \
    && qmake \
    && make \
    && make install

COPY requirements.txt yubikey-manager-qt/
RUN mkdir -p yubikey-manager-qt/appDir/usr \
    && eval "$(pyenv init --path)" \
    && pyenv global 3.11.1 \
    && cd yubikey-manager-qt \
    && pip3 install --upgrade pip \
    && pip3 install -r requirements.txt \
    && cp -R /root/.pyenv/versions/3.11.1/* appDir/usr

COPY . yubikey-manager-qt
RUN eval "$(pyenv init --path)" \
    && pyenv global 3.11.1 \
    && cd yubikey-manager-qt \
    && qmake \
    && make \
    && cp resources/ykman-gui.desktop appDir/ \
    && cp resources/icons/ykman.png appDir/ \
    && cp ./ykman-gui/ykman-gui appDir/usr/bin/ \
    && wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" \
    && wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" \
    && chmod a+x linuxdeployqt*.AppImage \
    && chmod a+x appimagetool*.AppImage \
    && unset QTDIR \
    && unset QT_PLUGIN_PATH \
    && unset LD_LIBRARY_PATH
CMD cd yubikey-manager-qt \
    && ./linuxdeployqt*.AppImage appDir/usr/bin/ykman-gui -qmldir=./ykman-gui/qml -bundle-non-qt-libs \
    && rm appDir/AppRun \
    && cp ./resources/linux/AppRun appDir/ \
    && chmod a+x appDir/AppRun \
    && ./appimagetool*.AppImage appDir
