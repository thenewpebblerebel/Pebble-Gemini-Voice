#!/bin/bash
set -euo pipefail
# Build patched wheels for legacy packages into /tmp/wheels
WORKDIR=$(pwd)
TMP_BUILD=/tmp/build
WHEEL_DIR=/tmp/wheels
mkdir -p "$TMP_BUILD" "$WHEEL_DIR"

echo "Building patched pypng..."
cd "$TMP_BUILD"
curl -sSLO https://files.pythonhosted.org/packages/source/p/pypng/pypng-0.0.17.tar.gz
tar -xzf pypng-0.0.17.tar.gz
cd pypng-0.0.17
python /tmp/vendor/pypng_patch.py setup.py
python -m pip wheel . -w "$WHEEL_DIR"

echo "Building patched pyserial..."
cd "$TMP_BUILD"
curl -sSLO https://files.pythonhosted.org/packages/source/p/pyserial/pyserial-2.7.tar.gz
tar -xzf pyserial-2.7.tar.gz
cd pyserial-2.7
python /tmp/vendor/pyserial_patch.py setup.py
python -m pip wheel . -w "$WHEEL_DIR"

echo "Wheels built:" && ls -la "$WHEEL_DIR"
