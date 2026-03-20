#!/bin/bash
# _ns/scripts/configure_nsuite.sh
# Configures the nSuite edition of X11Libre with minimalist flags.

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$SOURCE_DIR/build"

echo "⚙️  Configuring X11Libre nSuite Edition..."

# Use the NILA-spec build flags (DRM/KMS enabled for Intel Arc)
meson setup "$BUILD_DIR" "$SOURCE_DIR" \
    --reconfigure \
    -Dglx=true \
    -Dglamor=true \
    -Ddri3=true \
    -Ddrm=true \
    -Dxinerama=false \
    -Dprefix=/usr/local/x11libre

echo "✅ Configuration complete in $BUILD_DIR"
