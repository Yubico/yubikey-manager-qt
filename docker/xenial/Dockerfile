FROM ubuntu:xenial
RUN apt-get update -qq
RUN apt-get install -qq software-properties-common
RUN add-apt-repository -y ppa:yubico/stable
RUN apt-get update -qq && apt-get -qq upgrade
RUN apt-get install -qq \
    git \
    swig \
    python \
    libpcsclite-dev \
    libssl-dev \
    libffi-dev \
    libykpers-1-1 \
    libu2f-host0 \
    qtbase5-dev \
    qtdeclarative5-dev \
    libqt5svg5-dev \
    python3-dev \
    python3-pip \
    python3-pyscard \
    devscripts \
    debhelper \
    qml-module-qtquick-controls \
    python3-pip \
    python3-dev
RUN git clone --recursive https://github.com/Yubico/yubikey-manager-qt
RUN echo "DEFINES += QT_NO_DEBUG_OUTPUT" >> yubikey-manager-qt/vendor/pyotherside/src/src.pro
RUN cd yubikey-manager-qt/vendor/pyotherside && qmake -qt=qt5 && make && make install
RUN cd yubikey-manager-qt && qmake -qt=qt5 && make
RUN cd yubikey-manager-qt && debuild -us -uc
RUN mkdir /deploy
RUN mv /yubikey-manager-qt_* /deploy
RUN cd / && tar czf yubikey-manager-debian-qt-builds.tar.gz deploy
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
CMD (cd yubikey-manager-qt/ykman-cli && ./test.py)
