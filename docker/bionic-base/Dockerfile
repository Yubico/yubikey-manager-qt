FROM ubuntu:bionic
LABEL description="Base image for yubikey-manager-qt CI builds"
RUN apt-get update -qq
RUN apt-get install -qq software-properties-common
RUN add-apt-repository -y ppa:yubico/stable
RUN apt-get -qq update && apt-get -qq upgrade && apt-get install -y git devscripts equivs python3-dev python3-pip
