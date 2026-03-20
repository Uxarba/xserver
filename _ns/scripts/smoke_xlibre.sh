#!/bin/bash
# _ns/scripts/smoke_xlibre.sh
# Phase 2: Pure X server smoke test.

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPTS_DIR/../.." && pwd)"
XORG_BIN="$BASE_DIR/build/hw/xfree86/Xorg"
LOG_DIR="$BASE_DIR/_ns/logs/smoke_$(date +%Y%m%d_%H%M%S)"

# 1. Find a free display
DISPLAY_NUM=$("$SCRIPTS_DIR/find_display.sh")
if [[ $? -ne 0 ]]; then
    echo "❌ $DISPLAY_NUM"
    exit 1
fi

export DISPLAY=":$DISPLAY_NUM"
mkdir -p "$LOG_DIR"

echo "🚀 Starting XLibre Smoke Test on $DISPLAY..."
echo "📂 Logs: $LOG_DIR"
echo "💡 TIP: If the screen hangs, use 'Ctrl+Alt+F2' and run 'pkill -f Xorg' to recover."

# 2. Start Xorg
# We use -retro so we can see something (the grid) if we switch to it
# We use -noreset to prevent it from closing immediately
# We use -modulepath to find our staged drivers (modesetting, etc)
# We use -keeptty -seat seat0 vt$VT to allow non-root execution
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
echo "⏳ Waiting for $DISPLAY to be ready (Timeout: 15s)..."
RETRY=0
while ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
    sleep 1
    ((RETRY++))
    if [[ $RETRY -gt 15 ]]; then
        echo "❌ Timeout waiting for X server."
        echo "🔎 Checking last lines of $LOG_DIR/xorg.log:"
        tail -n 5 "$LOG_DIR/xorg.log"
        kill $X_PID 2>/dev/null
        exit 1
    fi
done

echo "✅ X Server is UP!"

# 4. Start a simple client (xsetroot)
if command -v xsetroot >/dev/null 2>&1; then
    echo "🎨 Setting background color..."
    xsetroot -display "$DISPLAY" -solid "#223344"
fi

# 5. Interaction Check (xdpyinfo)
xdpyinfo -display "$DISPLAY" > "$LOG_DIR/xdpyinfo.txt"

echo "🏁 Smoke test successful! Display $DISPLAY is alive."
echo "Press Ctrl+C to terminate or wait 10 seconds..."
sleep 10

# 6. Cleanup
echo "🧹 Cleaning up..."
kill $X_PID
wait $X_PID 2>/dev/null

echo "✅ Done."
