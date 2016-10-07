TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

# Icon files
RC_ICONS = resources/icons/ykman.ico
ICON = resources/icons/ykman.icns


DISTFILES += \
    yubikey.py
