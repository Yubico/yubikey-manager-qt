QT += core qml
QT -= gui
TARGET = ykman
CONFIG += c++11 console
CONFIG -= app_bundle
TEMPLATE = app
SOURCES += main.cpp

buildqrc.commands = python3 ../build_qrc.py ${QMAKE_FILE_IN}
buildqrc.input = QRC_JSON
buildqrc.output = ${QMAKE_FILE_IN_BASE}.qrc
buildqrc.variable_out = RESOURCES
QMAKE_STRIPFLAGS_LIB  += --strip-unneeded
QMAKE_EXTRA_COMPILERS += buildqrc
QRC_JSON = resources.json
# Generate first time
system(python3 ../build_qrc.py resources.json)

# Install python dependencies with pip for win and mac
mac|win32 {
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

# On mac, embedd a Info.plist file in the binary, needed for codesign
macx{
    QMAKE_LFLAGS += -sectcreate __TEXT __info_plist $$shell_quote(../resources/mac/Info.plist.cli)
}
