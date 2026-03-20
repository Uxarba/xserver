#!/bin/bash
# _ns/scripts/nsession_min.sh
# Phase 4: Minimal NILA Session (XLibre + Openbox + Core Daemons).

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPTS_DIR/../.." && pwd)"
XORG_BIN="$BASE_DIR/build/hw/xfree86/Xorg"
PREVIEW_DAEMON="/home/afr0s/Projects/nemo_hoverwave/n_preview_daemon_c"
LOG_DIR="$BASE_DIR/_ns/logs/nsession_$(date +%Y%m%d_%H%M%S)"

# 1. Find a free display
DISPLAY_NUM=$("$SCRIPTS_DIR/find_display.sh")
if [[ $? -ne 0 ]]; then
    echo "❌ $DISPLAY_NUM"
    exit 1
fi

export DISPLAY=":$DISPLAY_NUM"
mkdir -p "$LOG_DIR"
cd "$BASE_DIR"

echo "🚀 Starting NILA Minimal Session on $DISPLAY..."
echo "📂 Logs: $LOG_DIR"

# 2. Start Xorg
MODULE_DIR="$BASE_DIR/lib/xorg/modules"
"$XORG_BIN" "$DISPLAY" -retro -logfile "$LOG_DIR/xorg.log" -modulepath "$MODULE_DIR" -novtswitch -sharevts -extension XNAMESPACE > "$LOG_DIR/stdout.log" 2> "$LOG_DIR/stderr.log" &
X_PID=$!

# 3. Wait for readiness
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

# 4. Start Openbox
openbox --display "$DISPLAY" > "$LOG_DIR/openbox.log" 2>&1 &
WM_PID=$!
sleep 1

# 5. Start NILA Core Daemons
echo "📡 Starting n_preview_daemon_c..."
"$PREVIEW_DAEMON" > "$LOG_DIR/preview_daemon.log" 2>&1 &
DAEMON_PID=$!

# 6. Start a terminal for interactivity
if command -v xterm >/dev/null 2>&1; then
    xterm -display "$DISPLAY" -title "NILA Minimal Session" &
fi

echo "🏁 NILA Minimal Session is active on $DISPLAY."
echo "Use './_ns/scripts/stop_session.sh $DISPLAY_NUM' to terminate."
echo "Use './_ns/scripts/check_session.sh $DISPLAY_NUM' for health check."
