TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

VERSION = 0.2.1


# Default rules for deployment.
include(deployment.pri)

!macx {
    include(vendor/qt-solutions/qtsingleapplication/src/qtsingleapplication.pri)
}

# Icon files
RC_ICONS = resources/icons/ykman.ico

macx {
    ICON = resources/icons/ykman.icns
    QMAKE_INFO_PLIST = ../resources/mac/Info.plist.in
}

DISTFILES += \
    yubikey.py
