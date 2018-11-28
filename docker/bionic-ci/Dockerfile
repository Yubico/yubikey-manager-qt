FROM yubikey-manager-qt-ci-base

RUN apt-get update -qq && apt-get install -qq qtdeclarative5-dev-tools
RUN pip3 install pre-commit flake8

WORKDIR /sources/yubikey-manager-qt

COPY qmllint-qt5.sh  /usr/local/bin/qmllint

CMD ["pre-commit", "run", "--all-files"]
