#!/bin/bash
# _ns/scripts/nSession.sh
# Phase 6: Production NILA Session Orchestrator.
# Ties together X11Libre, Openbox, and NILA Core Daemons.

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPTS_DIR/../.." && pwd)"
XORG_BIN="$BASE_DIR/build/hw/xfree86/Xorg"
PREVIEW_DAEMON="/home/afr0s/Projects/nemo_hoverwave/n_preview_daemon_c"
SESSION_LOG_DIR="$BASE_DIR/_ns/logs/session_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$SESSION_LOG_DIR"
echo "🌟 Starting NILA Production Session..."
echo "📂 Session Logs: $SESSION_LOG_DIR"

# 1. Find a free display
DISPLAY_NUM=$("$SCRIPTS_DIR/find_display.sh")
if [[ $? -ne 0 ]]; then
    echo "❌ $DISPLAY_NUM"
    exit 1
fi

export DISPLAY=":$DISPLAY_NUM"
echo "🖥️ Using DISPLAY $DISPLAY"

# 2. Start XLibre (Production Flags)
# Detect VT if on a TTY
VT_ARG=""
if [[ $(tty) =~ /dev/tty([0-9]+) ]]; then
    VT_NUM="${BASH_REMATCH[1]}"
    VT_ARG="vt$VT_NUM"
    echo "📟 Detected TTY$VT_NUM, using $VT_ARG"
fi

MODULE_DIR="$BASE_DIR/lib/xorg/modules"

echo "🎯 Launching XLibre..."
"$XORG_BIN" "$DISPLAY" \
    -logfile "$SESSION_LOG_DIR/xorg.log" \
    -modulepath "$MODULE_DIR" \
    -novtswitch \
    -sharevts \
    -keeptty \
    -seat seat0 \
    $VT_ARG \
    -extension XNAMESPACE \
    > "$SESSION_LOG_DIR/xorg.stdout.log" 2> "$SESSION_LOG_DIR/xorg.stderr.log" &
X_PID=$!

# 3. Wait for readiness
echo "⏳ Waiting for X Server..."
RETRY=0
while ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
    sleep 1
    ((RETRY++))
    if [[ $RETRY -gt 15 ]]; then
        echo "❌ Timeout waiting for X server."
        kill $X_PID 2>/dev/null
        exit 1
    fi
done
echo "✅ X Server is UP!"

# 4. Start Window Manager (Openbox)
echo "💎 Launching Openbox..."
openbox --display "$DISPLAY" --config-file /dev/null > "$SESSION_LOG_DIR/openbox.log" 2>&1 &
OB_PID=$!

# 5. Start NILA Core Daemons
if [[ -f "$PREVIEW_DAEMON" ]]; then
    echo "🔊 Launching n_preview_daemon_c (nAudio)..."
    "$PREVIEW_DAEMON" > "$SESSION_LOG_DIR/n_preview.log" 2>&1 &
    DAEMON_PID=$!
fi

# 6. Status Report
echo "🚀 NILA Session established!"
echo "   - X Server PID: $X_PID"
echo "   - Openbox PID: $OB_PID"
echo "   - nAudio PID: ${DAEMON_PID:-N/A}"
echo ""
echo "💡 To stop this session, run: ./_ns/scripts/stop_session.sh"
echo "Press Ctrl+C to watch logs or logout of TTY to terminate."

# Keep alive and monitor
wait $X_PID
