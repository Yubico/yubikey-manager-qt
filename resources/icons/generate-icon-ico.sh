#!/bin/sh

# Exit on error
set -e

original="$(pwd)/resources/icons/ykman.svg"
output="$(pwd)/resources/icons/ykman.ico"
tmpdir="$(pwd)/resources/icons/ico-pngs"

mkdir "$tmpdir"

for size in 16 32 48 256; do
  inkscape -z -e "$tmpdir"/$size.png -w $size -h $size "$original"
done

magick convert "$tmpdir"/*.png "$output"

rm -r "$tmpdir"
