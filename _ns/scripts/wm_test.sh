#!/bin/bash
# _ns/scripts/wm_test.sh
# Phase 3: Window Manager (Openbox) Integration Test.

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPTS_DIR/../.." && pwd)"
XORG_BIN="$BASE_DIR/build/hw/xfree86/Xorg"
LOG_DIR="$BASE_DIR/_ns/logs/wm_$(date +%Y%m%d_%H%M%S)"

# 1. Find a free display
DISPLAY_NUM=$("$SCRIPTS_DIR/find_display.sh")
if [[ $? -ne 0 ]]; then
    echo "❌ $DISPLAY_NUM"
    exit 1
fi

export DISPLAY=":$DISPLAY_NUM"
mkdir -p "$LOG_DIR"

echo "🚀 Starting XLibre WM Test on $DISPLAY..."
echo "📂 Logs: $LOG_DIR"

# 2. Start Xorg
# We use -modulepath to find our staged drivers (modesetting, libinput, etc)
MODULE_DIR="$BASE_DIR/lib/xorg/modules"

# Detect current VT number if on a TTY
VT_ARG=""
if [[ $(tty) =~ /dev/tty([0-9]+) ]]; then
    VT_NUM="${BASH_REMATCH[1]}"
    VT_ARG="vt$VT_NUM"
    echo "📟 Detected TTY$VT_NUM, using $VT_ARG"
fi

"$XORG_BIN" "$DISPLAY" \
    -retro \
    -logfile "$LOG_DIR/xorg.log" \
    -modulepath "$MODULE_DIR" \
    -novtswitch \
    -sharevts \
    -keeptty \
    -seat seat0 \
    $VT_ARG \
    > "$LOG_DIR/stdout.log" 2> "$LOG_DIR/stderr.log" &
X_PID=$!

# 3. Wait for readiness
echo "⏳ Waiting for X server..."
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
echo "📦 Starting Openbox..."
openbox --display "$DISPLAY" > "$LOG_DIR/openbox.log" 2>&1 &
WM_PID=$!

sleep 2

# 5. Verify WM
if xprop -display "$DISPLAY" -root | grep -i "openbox" >/dev/null 2>&1; then
    echo "✅ Openbox is managing the root window."
else
    echo "⚠️  Openbox check failed (or not found in xprop)."
fi

# 6. Start a terminal for visibility
if command -v xterm >/dev/null 2>&1; then
    echo "📟 Starting xterm..."
    xterm -display "$DISPLAY" -bg "#111111" -fg "#cccccc" &
fi

echo "🏁 WM Test active. Display $DISPLAY is under management."
echo "Press Ctrl+C to terminate or wait 15 seconds..."
sleep 15

# 7. Cleanup
echo "🧹 Cleaning up..."
kill $WM_PID $X_PID 2>/dev/null
wait $X_PID 2>/dev/null

echo "✅ Done."
