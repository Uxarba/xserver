#!/bin/bash
# _ns/scripts/stop_session.sh
# Safely terminates an X11Libre nSuite session.

if [ -z "$1" ]; then
    echo "Usage: ./stop_session.sh <DISPLAY_NUMBER>"
    echo "Example: ./stop_session.sh 1"
    exit 1
fi

DISPLAY_NUM=$1
DISPLAY=":$DISPLAY_NUM"

echo "🛑 Stopping NILA session on $DISPLAY..."

# 1. Ask the X server PID via its lockfile
LOCKFILE="/tmp/.X$DISPLAY_NUM-lock"
if [ -f "$LOCKFILE" ]; then
    X_PID=$(cat "$LOCKFILE" | tr -d ' ')
    if [ -n "$X_PID" ]; then
        echo "🔪 Terminating X server (PID $X_PID)..."
        kill "$X_PID"
        
        # Give it a moment to clean up
        sleep 2
        
        if ps -p "$X_PID" > /dev/null; then
            echo "⚠️  Server still alive, force killing..."
            kill -9 "$X_PID"
        fi
    fi
else
    echo "⚠️  No lockfile found for $DISPLAY."
fi

# 2. Cleanup stray sockets if any
rm -f "/tmp/.X11-unix/X$DISPLAY_NUM"
rm -f "$LOCKFILE"

echo "✅ Session $DISPLAY stopped."
