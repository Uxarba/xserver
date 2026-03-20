#!/bin/bash
# _ns/scripts/build_nsuite.sh
# Compiles the X11Libre nSuite Edition.

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$SOURCE_DIR/build"

echo "🔨 Building X11Libre nSuite Edition..."

ninja -C "$BUILD_DIR" || {
    echo "❌ Build FAILED (check ninja output above)."
    exit 1
}

echo "✅ Build complete."
echo "Binary: $BUILD_DIR/hw/xfree86/Xorg"
