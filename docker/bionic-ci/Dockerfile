FROM ubuntu:bionic
RUN apt-get update -qq
RUN apt-get install -qq software-properties-common
RUN add-apt-repository -y ppa:yubico/stable
RUN apt-get -qq update && apt-get -qq upgrade && apt-get install -y git devscripts equivs python3-dev python3-pip

RUN apt-get update -qq && apt-get install -qq qtdeclarative5-dev-tools
RUN pip3 install pre-commit flake8

WORKDIR /sources/yubikey-manager-qt

COPY qmllint-qt5.sh  /usr/local/bin/qmllint

CMD ["pre-commit", "run", "--all-files"]
