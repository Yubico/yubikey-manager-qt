FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
  git \
  python3-pip \
  qtdeclarative5-dev-tools
RUN pip3 install pre-commit flake8

VOLUME /sources
WORKDIR /sources/yubikey-manager-qt

COPY qmllint-qt5.sh  /usr/local/bin/qmllint

CMD ["pre-commit", "run", "--all-files"]
