#!/usr/bin/env python3

from subprocess import check_output
import re


def main():
    out = check_output(['./ykman', '-v'])

    assert re.search(br'libykpers\s+(1\.\d+\.\d+)', out)
    assert re.search(br'libu2f-host0?\s+(1\.\d+\.\d+)', out)
    assert re.search(br'libusb\s+(1\.\d+\.\d+)', out)


if __name__ == '__main__':
    main()
