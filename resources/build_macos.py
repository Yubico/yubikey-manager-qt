#!/usr/bin/env python

import sys
from subprocess import check_call, check_output, CalledProcessError

PYTHON_VERSION = '3.4.4'
PYTHON_PATH = '/Library/Frameworks/Python.framework/Versions/3.4/bin/python3'


def verify_qt():
    try:
        check_call(['qmake'])
        check_call(['macdeployqt'])
    except OSError:
        print("Problem with Qt installation.")
        sys.exit()


def verify_python3():
    try:
        version = check_output(['python3', '--version']).decode()
        python_path = check_output(['which', 'python3']).decode()
        pip_path = check_output(['which', 'pip3']).decode()
        if PYTHON_VERSION not in version:
            raise ValueError
        if PYTHON_PATH not in python_path:
            raise ValueError
        if PYTHON_PATH not in pip_path:
            raise ValueError
    except (ValueError, CalledProcessError, OSError):
        print("Problem with Python 3 installation.")
        sys.exit()


def verify_virtualenv():
    try:
        packages = check_output(['pip3', 'list'])
        if 'virtualenv' not in packages:
            print("virtualenv not installed, installing...")
            check_call('pip3', 'install', 'virtualenv')
    except CalledProcessError:
        print("Failed installing virtualenv.")
        sys.exit()

verify_qt()
verify_python3()
verify_virtualenv()
# verify_libs()
# verify_ykman()
# build_binaries()
# package_qt()
# package_python()
# package_libs()
# relink_libs()
# package_ykman()
