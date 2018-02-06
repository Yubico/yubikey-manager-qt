#!/bin/bash
# Generate `VERSION` file and run `../scripts/make-ppa`
#
# Command line arguments are passed through to `make-ppa`.

die() {
  echo "Error occurred - exiting!" >&2
  cleanup
  exit 1
}

python3 compute-version.py yubikey-manager-qt- > VERSION

echo "Version:"
cat VERSION

../scripts/make-ppa "$@"
