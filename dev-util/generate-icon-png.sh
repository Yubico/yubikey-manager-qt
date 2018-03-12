#!/bin/sh

# Exit on error
set -e

original="$(pwd)/resources/icons/ykman.svg"
output="$(pwd)/resources/icons/ykman.png"

inkscape -z -e "$output" -w 128 -h 128 "$original"
cp "$output" ykman-gui/images/windowicon.png
