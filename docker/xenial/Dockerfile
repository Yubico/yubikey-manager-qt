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
    qt5-default \
    qml-module-qtquick-controls \
    qml-module-qtquick-dialogs \
    qml-module-io-thp-pyotherside \
    python3-pip \
    python3-dev \
    locales
RUN pip3 install --upgrade pip
COPY . yubikey-manager-qt
RUN tar xfa yubikey-manager-qt/ykman-deb.tar.gz
# Make sure .deb files exist
RUN ls /deb/python3-yubikey-manager_*.deb
RUN ls /deb/yubikey-manager_*.deb
RUN dpkg -i /deb/python3-yubikey-manager_*.deb; exit 0
RUN dpkg -i /deb/yubikey-manager_*.deb; exit 0
RUN apt-get install -f -qq
RUN cd yubikey-manager-qt && qmake -qt=qt5 && make
RUN cd yubikey-manager-qt && debuild -us -uc
RUN mv /yubikey-manager-qt_* /deb
RUN cd / && tar czf yubikey-manager-qt-debian-packages.tar.gz deb
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
CMD (cd yubikey-manager-qt/ykman-cli && ./test.py)
