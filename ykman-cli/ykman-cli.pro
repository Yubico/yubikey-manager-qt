QT += core qml
QT -= gui

CONFIG += c++11

TARGET = ykman
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += cli.cpp

RESOURCES += qml.qrc
macx{
    QMAKE_LFLAGS += -sectcreate __TEXT __info_plist $$shell_quote(../resources/mac/Info.plist.cli)
}
QML_IMPORT_PATH =
