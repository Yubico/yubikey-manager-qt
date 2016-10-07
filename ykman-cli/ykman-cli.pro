QT += core qml
QT -= gui

CONFIG += c++11

TARGET = ykman
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += cli.cpp

RESOURCES += qml.qrc

QML_IMPORT_PATH =
