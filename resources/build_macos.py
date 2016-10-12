#!/usr/bin/env python

import sys
import os
from subprocess import call, check_call, check_output, CalledProcessError
from distutils.util import strtobool

PYTHON_VERSION = '3'


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
        print("brew install qt5")
        print("brew link qt5 -f")
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
        print("brew install python3")
        print("pip3 install --upgrade pip setuptools wheel")
        sys.exit()


def verify_virtualenv():
    try:
        packages = check_output(['pip3', 'list']).decode()
        if 'virtualenv' not in packages:
            print("virtualenv not installed, installing...")
            check_call(['pip3', 'install', 'virtualenv'])
    except CalledProcessError:
        print("Failed installing virtualenv.")
        sys.exit()


def verify_libs():
    libs = os.listdir("lib")
    missing = False
    print("Verifying library dependencies...")
    for line in open('libs.txt'):
        lib = line.strip() + '.dylib'
        if lib in libs:
            print("Found {0}.".format(lib))
        else:
            missing = True
            print("Missing dependency {0}.".format(lib))
            #TODO: Install dependencies?
    if missing:
        sys.exit()


def install_libs():
    # TODO: Is there a better way?
    # DYLD_FALLBACK_LIBRARY_PATH?
    print("Copying libs to /usr/local/lib/...")
    call('cp -R ./lib/* /usr/local/lib/', shell=True)


def install_ykman():
    print("Installing ykman in a virtualenv...")
    # swig needed to build pyscard
    check_call(['virtualenv', '--no-wheel', 'ykman-env'])
    call('source ./ykman-env/bin/activate && pip3 install '
        '-e ./vendor/yubikey-manager/.[cli]', shell=True)


# verify_path()
verify_brew()
verify_qt()
verify_swig()
verify_python3()
verify_virtualenv()
verify_libs()
install_libs()
install_ykman()
# build_binaries()
# package_qt()
# package_python()
# package_libs()
# relink_libs()
# package_ykman()
