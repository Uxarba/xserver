#!/bin/bash
# _ns/scripts/check_session.sh
# Health check for an active NILA session.

if [ -z "$1" ]; then
    echo "Usage: ./check_session.sh <DISPLAY_NUMBER>"
    exit 1
fi

DISPLAY_NUM=$1
DISPLAY=":$DISPLAY_NUM"

echo "🔍 Checking health for session $DISPLAY..."

# 1. X Server Check
if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    echo "✅ X Server: Connected"
else
    echo "❌ X Server: Not responding"
fi

# 2. Window Manager Check
if xprop -display "$DISPLAY" -root | grep -i "openbox" >/dev/null 2>&1; then
    echo "✅ WM: Openbox is active"
else
    echo "❌ WM: Openbox not detected"
fi

# 3. Daemon Check (n_preview_daemon_c)
if pgrep -f "n_preview_daemon_c" >/dev/null 2>&1; then
    echo "✅ Daemon: n_preview_daemon_c is running"
else
    echo "❌ Daemon: n_preview_daemon_c is NOT running"
fi

# 4. Socket Check
if [ -S "/tmp/nemo_preview.sock" ]; then
    echo "✅ Socket: /tmp/nemo_preview.sock exists"
else
    echo "❌ Socket: /tmp/nemo_preview.sock missing"
fi
