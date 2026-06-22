#!/bin/bash
# ~/.config/kmonad/kmonad-start.sh
# Manages kmonad instances for laptop + Keychron Q2
# Usage: kmonad-start.sh [start|stop|restart|q2-plug|q2-unplug]

KMONAD_DIR="$HOME/.config/kmonad"
LAPTOP_CFG="$KMONAD_DIR/laptop.kbd"
Q2_TEMPLATE="$KMONAD_DIR/q2.kbd"
Q2_RUNTIME="/tmp/kmonad-q2-runtime.kbd"
Q2_PID="/tmp/kmonad-q2.pid"
LAPTOP_PID="/tmp/kmonad-laptop.pid"

find_q2_device() {
    # Look for the Keychron Q2 keyboard device (not mouse/consumer/system)
    for dev in /dev/input/by-id/*Keychron*Q2*event-kbd; do
        [ -e "$dev" ] && echo "$dev" && return 0
    done
    # Fallback: search by name
    for event in /dev/input/event*; do
        name=$(cat "/sys/class/input/$(basename "$event")/device/name" 2>/dev/null)
        if [[ "$name" == "Keychron Keychron Q2" ]]; then
            echo "$event"
            return 0
        fi
    done
    return 1
}

start_laptop() {
    if [ -f "$LAPTOP_PID" ] && kill -0 "$(cat "$LAPTOP_PID")" 2>/dev/null; then
        echo "Laptop kmonad already running (PID $(cat "$LAPTOP_PID"))"
        return
    fi
    if [ ! -e "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ]; then
        echo "Laptop keyboard not found, skipping"
        return
    fi
    echo "Starting laptop kmonad..."
    kmonad "$LAPTOP_CFG" &
    echo $! > "$LAPTOP_PID"
}

start_q2() {
    if [ -f "$Q2_PID" ] && kill -0 "$(cat "$Q2_PID")" 2>/dev/null; then
        echo "Q2 kmonad already running (PID $(cat "$Q2_PID"))"
        return
    fi
    local device
    device=$(find_q2_device)
    if [ -z "$device" ]; then
        echo "Q2 not connected, skipping"
        return
    fi
    echo "Found Q2 at: $device"
    # Generate runtime config with actual device path
    sed "s|KMONAD_Q2_DEVICE|$device|" "$Q2_TEMPLATE" > "$Q2_RUNTIME"
    echo "Starting Q2 kmonad..."
    kmonad "$Q2_RUNTIME" &
    echo $! > "$Q2_PID"
}

stop_q2() {
    if [ -f "$Q2_PID" ]; then
        local pid
        pid=$(cat "$Q2_PID")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping Q2 kmonad (PID $pid)..."
            kill "$pid" 2>/dev/null
            wait "$pid" 2>/dev/null
        fi
        rm -f "$Q2_PID" "$Q2_RUNTIME"
    fi
}

stop_all() {
    stop_q2
    if [ -f "$LAPTOP_PID" ]; then
        local pid
        pid=$(cat "$LAPTOP_PID")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping laptop kmonad (PID $pid)..."
            kill "$pid" 2>/dev/null
        fi
        rm -f "$LAPTOP_PID"
    fi
    # Clean up any orphans
    pkill -f "kmonad.*laptop.kbd" 2>/dev/null
    pkill -f "kmonad.*q2" 2>/dev/null
}

case "${1:-start}" in
    start)
        stop_all
        sleep 0.3
        start_laptop
        start_q2
        ;;
    stop)
        stop_all
        ;;
    restart)
        stop_all
        sleep 0.3
        start_laptop
        start_q2
        ;;
    q2-plug)
        # Called by udev when Q2 is plugged in
        sleep 1  # Give device time to settle
        start_q2
        ;;
    q2-unplug)
        # Called by udev when Q2 is unplugged
        stop_q2
        ;;
    status)
        echo -n "Laptop: "
        if [ -f "$LAPTOP_PID" ] && kill -0 "$(cat "$LAPTOP_PID")" 2>/dev/null; then
            echo "running (PID $(cat "$LAPTOP_PID"))"
        else
            echo "stopped"
        fi
        echo -n "Q2:     "
        if [ -f "$Q2_PID" ] && kill -0 "$(cat "$Q2_PID")" 2>/dev/null; then
            echo "running (PID $(cat "$Q2_PID"))"
        else
            echo "stopped"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|q2-plug|q2-unplug|status}"
        exit 1
        ;;
esac
