#!/bin/bash

# Exit on error
set -e

original="$(pwd)/resources/icons/ykman.svg"
name=${original%.*}
dest="$name".iconset
mkdir "$dest"

for size in 16 32 128 256 512; do
  inkscape -z -e "$dest/icon_${size}x${size}.png" -w $size -h $size "$original"
done

iconutil -c icns "$dest"
rm -R "$dest"
