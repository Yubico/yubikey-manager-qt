TEMPLATE = app
QT += qml quick widgets quickcontrols2
CONFIG += c++11
SOURCES += main.cpp

# This is the internal verson number, Windows requires 4 digits.
win32|win64 {
    VERSION = 1.2.6.0
} else {
    VERSION = 1.2.6
}
# This is the version shown on the About page
DEFINES += APP_VERSION=\\\"1.2.6\\\"

message(Version of this build: $$VERSION)

buildqrc.commands = python3 ../build_qrc.py ${QMAKE_FILE_IN}
buildqrc.input = QRC_JSON
buildqrc.output = ${QMAKE_FILE_IN_BASE}.qrc
buildqrc.variable_out = RESOURCES

QMAKE_STRIPFLAGS_LIB  += --strip-unneeded

QMAKE_EXTRA_COMPILERS += buildqrc
QRC_JSON = resources.json

# Generate first time
system(python3 ../build_qrc.py resources.json)

# Install python dependencies with pip on mac and win
win32|macx {
    pip.target = pymodules
    QMAKE_EXTRA_TARGETS += pip
    PRE_TARGETDEPS += pymodules
    QMAKE_CLEAN += -r pymodules
}

macx {
    pip.commands = python3 -m venv pymodules && source pymodules/bin/activate && pip3 install -r ../requirements.txt && deactivate
}
!macx {
    pip.commands = pip3 install -r ../requirements.txt --target pymodules
}

win32 {
    QMAKE_CFLAGS += /guard:cf
    QMAKE_CXXFLAGS += /guard:cf
    QMAKE_LFLAGS += /guard:cf
}

# Default rules for deployment.
include(deployment.pri)


# Icon file
RC_ICONS = ../resources/icons/ykman.ico

# Mac specific configuration
macx {
    ICON = ../resources/icons/ykman.icns
    QMAKE_INFO_PLIST = ../resources/mac/Info.plist.in
    QMAKE_POST_LINK += cp -rnf pymodules/lib/python3*/site-packages/ ykman-gui.app/Contents/Resources/pymodules/
}

# For generating a XML file with all strings.
lupdate_only {
  SOURCES = qml/*.qml \
  qml/slot/*.qml
}

DISTFILES += \
    py/yubikey.py
