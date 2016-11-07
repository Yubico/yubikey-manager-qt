QT += core qml
QT -= gui

CONFIG += c++11

TARGET = ykman
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp

buildqrc.commands = ../build_qrc.py ${QMAKE_FILE_IN}
buildqrc.input = QRC_JSON
buildqrc.output = ${QMAKE_FILE_IN_BASE}.qrc
buildqrc.variable_out = RESOURCES

QMAKE_EXTRA_COMPILERS += buildqrc

QRC_JSON = resources.json

# Generate first time
system(../build_qrc.py resources.json)

pip.target = pymodules
pip.commands = pip3 install -r requirements.txt --target pymodules

QMAKE_EXTRA_TARGETS += pip

PRE_TARGETDEPS += pymodules
QMAKE_CLEAN += -r pymodules


macx{
    QMAKE_LFLAGS += -sectcreate __TEXT __info_plist $$shell_quote(../resources/mac/Info.plist.cli)
}
QML_IMPORT_PATH =
