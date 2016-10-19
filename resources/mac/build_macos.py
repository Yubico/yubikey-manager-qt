#!/usr/bin/env python

import sys
import os
from subprocess import call, check_call, check_output, CalledProcessError
from distutils.util import strtobool


PYTHON_VERSION = '3'


def sh(commands):
    call(commands, shell=True)


def verify_macos():
    if sys.platform != 'darwin':
        print("This script is only for macOS.")
        sys.exit()


def verify_path():
    if not os.getcwd().endswith('yubikey-manager-qt'):
        print(
            "Script should be run from root folder in repository, exiting...")
        sys.exit()


def verify_brew():
    print("Verifying brew installation...")
    try:
        check_call(['brew', '--version'])
    except OSError:
        print("Homebrew not found.")
        print("To install homebrew:")
        print('/usr/bin/ruby -e "$(curl -fsSL '
            'https://raw.githubusercontent.com/'
            'Homebrew/install/master/install)"')
        sys.exit()


def verify_qt():
    print("Verifying Qt installation...")
    try:
        check_call(['qmake', '--version'])
    except OSError:
        print("Qt not found.")
        print("To install Qt5 from homebrew:")
        print("brew install qt5 && brew link qt5 -f")
        sys.exit()


def verify_swig():
    print("Verifying Swig installation...")
    try:
        check_call(['swig', '-version'])
    except OSError:
        print("Swig not found.")
        print("To install Swig from homebrew:")
        print("brew install swig")
        sys.exit()


def verify_python3():
    print("Verifying Python 3 installation...")
    try:
        version = check_output(['python3', '--version']).decode()
        print("Python 3 is installed.")
        if PYTHON_VERSION not in version:
            raise ValueError
    except (ValueError, CalledProcessError, OSError):
        print("Python 3 not found.")
        print("To install Python 3 from pyenv:")
        print('brew install pyenv')
        print('env PYTHON_CONFIGURE_OPTS="--enable-framework CC=clang" pyenv install 3.5.2')
        print('echo "eval "$(pyenv init -)"" >> .profile')
        print('pyenv global 3.5.2')
        sys.exit()


def install_libs():
    print("Installing and copying dependencies from homebrew...")
    libs = ['ykpers', 'libyubikey', 'hidapi', 'libu2f-host', 'libusb']
    for lib in libs:
        sh('brew install ' + lib)
    sh("find /usr/local/Cellar/json-c/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libjson-c.dylib ';'")
    sh("find /usr/local/Cellar/ykpers/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libykpers-1.dylib ';'")
    sh("find /usr/local/Cellar/libyubikey/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libyubikey.dylib ';'")
    sh("find /usr/local/Cellar/hidapi/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libhidapi.dylib ';'")
    sh("find /usr/local/Cellar/libu2f-host/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libu2f-host.dylib ';'")
    sh("find /usr/local/Cellar/libusb/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libusb-1.0.dylib ';'")
    sh('chmod +w ./lib/*')


def verify_libs():
    if not os.path.isdir("lib"):
        sh("mkdir lib") 
    libs = os.listdir("lib")
    missing = False
    print("Verifying library dependencies...")
    for line in open('libs.txt'):
        dep = line.strip()
        for lib in libs:
            if dep in lib:
                print("Found {0}.".format(dep))
                break;
        else:
            missing = True
            print("Missing dependency {0} in lib folder.".format(dep))
    if missing:
        install_libs()


def install_ykman():
    print("Installing ykman in a separate folder.")
    sh('rm -rf ./ykman-install && mkdir ./ykman-install')
    check_call(['pip3', 'install', 'vendor/yubikey-manager/.[cli]',
        '--target=./ykman-install'])


def build_pyotherside():
    # TODO: Don't build if already built.
    print("Building pyotherside...")
    os.chdir('./vendor/pyotherside')
    sh('qmake')
    sh('make')
    sh('make install')
    os.chdir('../../')


def build_binaries():
    print("Building yubikey manager...")
    APP = './ykman-gui/ykman-gui.app'
    FRAMEWORKS = '/Contents/Frameworks'
    PYTHON_FRAMEWORK = FRAMEWORKS + '/Python.framework/Versions/3.5'
    SITE_PACKAGES = '/lib/python3.5/site-packages'
    sh('qmake yubikey-manager-qt.pro -r -spec macx-clang CONFIG+=x86_64')
    sh('rm -rf ' + APP)
    sh('make clean')
    sh('make')
    sh('cp ./ykman-cli/ykman ' + APP + '/Contents/MacOS/')
    sh('macdeployqt ' + APP + ' -qmldir=./ykman-gui/ -always-overwrite')
    sh('cp -a ~/.pyenv/versions/3.5.2/Python.framework ' + APP + FRAMEWORKS + '/') 
    sh('rm -rf ' + APP + PYTHON_FRAMEWORK + SITE_PACKAGES)
    sh('find ' + APP + ' -name __pycache__ -exec rm -rf {} \;')
    sh('rsync -r ./ykman-install/* ' + APP + PYTHON_FRAMEWORK + SITE_PACKAGES)
    sh('cp -R ./lib/* ' + APP + FRAMEWORKS + '/')


def relink_pyotherside():
    print("Relinking pyotherside...")
    # TODO: User must be yubico here..
    sh('install_name_tool -change '
    '/Users/yubico/.pyenv/versions/3.5.2/Python.framework/Versions/3.5/Python '
    '@executable_path/../Frameworks/Python.framework/Versions/3.5/Python ' 
    'ykman-gui/ykman-gui.app/Contents/Resources/'
    'qml/io/thp/pyotherside/libpyothersideplugin.dylib')


def relink_libs():
    print("Relinking libs...")
    os.chdir('./lib')
    sh('python ../resources/mac/relink.py')
    os.chdir('..')


def relink_ykman_cli():
    print("Relinking cli...")
    sh('install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml @executable_path/../Frameworks/QtQml.framework/Versions/5/QtQml ykman-gui/ykman-gui.app/Contents/MacOS/ykman')
    sh('install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork @executable_path/../Frameworks/QtNetwork.framework/Versions/5/QtNetwork ykman-gui/ykman-gui.app/Contents/MacOS/ykman')
    sh('install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/5/QtCore ykman-gui/ykman-gui.app/Contents/MacOS/ykman')


def main():
    verify_macos()
    verify_path()
    verify_brew()
    verify_qt()
    verify_swig()
    verify_python3()
    verify_libs()
    relink_libs()
    install_ykman()
    build_pyotherside()
    build_binaries()
    relink_pyotherside()
    relink_ykman_cli()    
    print("Done!")


if __name__ == '__main__':
    main()
