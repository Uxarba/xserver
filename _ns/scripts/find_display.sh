#!/bin/bash
# _ns/scripts/find_display.sh
# Probes for the first available X display starting from :1

MIN_DISPLAY=1
MAX_DISPLAY=99

for ((i=MIN_DISPLAY; i<=MAX_DISPLAY; i++)); do
    # Check for X-unix socket
    if [[ ! -S "/tmp/.X11-unix/X$i" ]]; then
        # Check for lockfile
        if [[ ! -f "/tmp/.X$i-lock" ]]; then
            # Final check with xdpyinfo (if available)
            if ! xdpyinfo -display ":$i" >/dev/null 2>&1; then
                echo "$i"
                exit 0
            fi
        fi
    fi
done

echo "Error: No free display found between :$MIN_DISPLAY and :$MAX_DISPLAY" >&2
exit 1
