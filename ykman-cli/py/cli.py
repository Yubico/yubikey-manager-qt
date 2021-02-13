#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys


def run(argv):
    sys.argv = argv
    from ykman.cli.__main__ import main

    try:
        return main()
    except SystemExit as e:
        return e.args[0]
