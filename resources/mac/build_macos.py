#!/usr/bin/env python

import sys
import os
from subprocess import call, check_call, check_output, CalledProcessError
from distutils.util import strtobool


PYTHON_VERSION = '3'


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
        print("To install Python 3 from Homebrew:")
        print(
            "brew install python3"
            " && pip3 install --upgrade pip setuptools wheel")
        sys.exit()


def install_libs():
    print("Installing and copying dependencies from homebrew...")
    call('brew install ykpers', shell=True) 
    call('brew install libyubikey', shell=True) 
    call('brew install hidapi', shell=True)
    call('brew install libu2f-host', shell=True)
    call('brew install libusb', shell=True)
    call("find /usr/local/Cellar/json-c/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libjson-c.dylib ';'", shell=True)
    call("find /usr/local/Cellar/ykpers/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libykpers-1.dylib ';'", shell=True)
    call("find /usr/local/Cellar/libyubikey/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libyubikey.dylib ';'", shell=True)
    call("find /usr/local/Cellar/hidapi/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libhidapi.dylib ';'", shell=True)
    call("find /usr/local/Cellar/libu2f-host/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libu2f-host.dylib ';'", shell=True)
    call("find /usr/local/Cellar/libusb/"
        " -type f -name '*.dylib' -exec cp '{}' lib/libusb-1.0.dylib ';'", shell=True)
    call('chmod +w ./lib/*', shell=True)


def verify_libs():
    if not os.path.isdir("lib"):
        call("mkdir lib", shell=True) 
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
    call('rm -rf ./ykman-install && mkdir ./ykman-install', shell=True)
    check_call(['pip3', 'install', 'vendor/yubikey-manager/.[cli]',
        '--target=./ykman-install'])


def build_pyotherside():
    # TODO: Don't build if already built.
    print("Building pyotherside...")
    os.chdir('./vendor/pyotherside')
    call('qmake', shell=True)
    call('make', shell=True)
    call('make install', shell=True)
    os.chdir('../../')


def build_binaries():
    print("Building yubikey manager...")
    call('qmake yubikey-manager-qt.pro -r -spec macx-clang CONFIG+=x86_64',
        shell=True)
    call('rm -rf ./ykman-gui/ykman-gui.app', shell=True)
    call('make clean', shell=True)
    call('make', shell=True)
    
    call('macdeployqt ./ykman-gui/ykman-gui.app/ -qmldir=./ykman-gui/ -always-overwrite', shell=True)
    call('cp -R /Library/Frameworks/Python.framework ykman-gui/ykman-gui.app/Contents/Frameworks/', shell=True)
    call('rm -rf ykman-gui/ykman-gui.app/Contents/Frameworks/Python.framework/Versions/3.5/Resources', shell=True)
    call('rm -rf ykman-gui/ykman-gui.app/Contents/Frameworks/Python.framework/Versions/3.5/share', shell=True)
    call('rm -rf ykman-gui/ykman-gui.app/Contents/Frameworks/Python.framework/Versions/3.5/bin', shell=True)
    call('rm -rf ykman-gui/ykman-gui.app/Contents/Frameworks/Python.framework/Versions/3.5/lib/python3.5/site-packages', shell=True)
    call('find ykman-gui/ykman-gui.app -name __pycache__ -exec rm -rf {} \;', shell=True)
    call('rsync -r ./ykman-install/* '
        './ykman-gui/ykman-gui.app/Contents/'
        'Frameworks/Python.framework/'
        'Versions/3.5/lib/python3.5/site-packages/', shell=True)
    call('cp ./ykman-cli/ykman ./ykman-gui/ykman-gui.app/Contents/MacOS/', shell=True)
    call('cp -R ./lib/* ./ykman-gui/ykman-gui.app/Contents/Frameworks/', shell=True)


def relink_pyotherside():
    print("Relinking pyotherside...")
    call('install_name_tool -change '
    '/Library/Frameworks/Python.framework/Versions/3.5/Python '
    '@executable_path/../Frameworks/Python.framework/Versions/3.5/Python ' 
    'ykman-gui/ykman-gui.app/Contents/Resources/'
    'qml/io/thp/pyotherside/libpyothersideplugin.dylib', shell=True)


def relink_libs():
    print("Relinking libs...")
    os.chdir('./lib')
    call('python ../resources/mac/relink.py', shell=True)
    os.chdir('..')


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
    print("Done!")


if __name__ == '__main__':
    main()
