TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

SOURCES += main.cpp

VERSION = 0.2.1


buildqrc.commands = python ../build_qrc.py ${QMAKE_FILE_IN}
buildqrc.input = QRC_JSON
buildqrc.output = ${QMAKE_FILE_IN_BASE}.qrc
buildqrc.variable_out = RESOURCES

QMAKE_EXTRA_COMPILERS += buildqrc

QRC_JSON = resources.json

# Generate first time
system(python ../build_qrc.py resources.json)

pip.target = pymodules
pip.commands = pip3 install -r requirements.txt --target pymodules

QMAKE_EXTRA_TARGETS += pip

PRE_TARGETDEPS += pymodules
QMAKE_CLEAN += -r pymodules


# Default rules for deployment.
include(deployment.pri)

!macx {
    include(vendor/qt-solutions/qtsingleapplication/src/qtsingleapplication.pri)
}

# Icon files
RC_ICONS = ../resources/icons/ykman.ico

macx {
    ICON = ../resources/icons/ykman.icns
    QMAKE_INFO_PLIST = ../resources/mac/Info.plist.in
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9 # Mavericks
    QMAKE_POST_LINK += cp -rn pymodules ykman-gui.app/Contents/MacOS/
}

lupdate_only {
  SOURCES = qml/*.qml \
  qml/slot/*.qml
}
