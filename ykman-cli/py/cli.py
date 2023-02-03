#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
try:
    from ykman._cli.__main__ import main
except (ModuleNotFoundError, ImportError):
    from ykman.cli.__main__ import main


def run(argv):
    sys.argv = argv

    try:
        return main()
    except SystemExit as e:
        return e.args[0]
