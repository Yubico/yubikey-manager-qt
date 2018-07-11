#!/bin/sh

# Exit on error
set -e

echo
echo "Generating PNG..."
./dev-util/generate-icon-png.sh

echo
echo "Generating ICO..."
./dev-util/generate-icon-ico.sh

echo
echo "Generating ICNS..."
./dev-util/generate-icon-icns.sh
