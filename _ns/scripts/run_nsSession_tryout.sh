#!/bin/bash
# _ns/scripts/run_nsSession_tryout.sh
# Starts the staged X11Libre server for a try-out session (Display :1).

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
XORG_BIN="$SOURCE_DIR/build/hw/xfree86/Xorg"
MODULE_PATH="$SOURCE_DIR/build/hw/xfree86" # Ensure modules are found

echo "🚀 Starting X11Libre nSuite try-out on :1..."

# Start Xorg on display :1
# We use -noreset to keep it alive between clients
# We might need to specify the config or module path
# For now, just a direct trial
"$XORG_BIN" :1 -retro -noreset -extension XNAMESPACE
