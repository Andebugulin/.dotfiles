#!/bin/bash
# ~/.config/kmonad/kmonad-daemon.sh
# Daemon that manages kmonad for laptop + Keychron Q2 with plug/unplug handling

KMONAD_DIR="$HOME/.config/kmonad"
LAPTOP_CFG="$KMONAD_DIR/laptop.kbd"
Q2_TEMPLATE="$KMONAD_DIR/q2.kbd"
Q2_RUNTIME="/tmp/kmonad-q2-runtime.kbd"
DAEMON_PID="/tmp/kmonad-daemon.pid"
Q2_LOG="/tmp/kmonad-q2.log"

LAPTOP_DEV="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

Q2_PATTERN="*Keychron*Q2*if02-event-kbd"
LAPTOP_PID=""
Q2_PID=""

find_q2_device() {
    for dev in /dev/input/by-id/$Q2_PATTERN; do
        [ -e "$dev" ] && echo "$dev" && return 0
    done
    return 1
}

# Wait until device is actually readable (not just symlink exists)
wait_for_device_ready() {
    local dev="$1"
    local tries=0
    while [ $tries -lt 20 ]; do
        if [ -r "$dev" ] && [ -c "$(readlink -f "$dev")" ]; then
            sleep 0.5
            return 0
        fi
        sleep 0.2
        tries=$((tries + 1))
    done
    return 1
}

start_laptop() {
    if [ -e "$LAPTOP_DEV" ]; then
        kmonad "$LAPTOP_CFG" &
        LAPTOP_PID=$!
        echo "[kmonad] Laptop started (PID $LAPTOP_PID)"
    fi
}

start_q2() {
    local device
    device=$(find_q2_device) || return 1

    if ! wait_for_device_ready "$device"; then
        echo "[kmonad] Q2 device found but not ready, skipping"
        return 1
    fi

    # Make sure no stale kmonad is holding the device
    pkill -f "kmonad.*q2-runtime" 2>/dev/null
    sleep 0.3

    sed "s|KMONAD_Q2_DEVICE|$device|" "$Q2_TEMPLATE" > "$Q2_RUNTIME"
    kmonad "$Q2_RUNTIME" > "$Q2_LOG" 2>&1 &
    local new_pid=$!

    # Verify kmonad actually started and didn't immediately crash
    sleep 1
    if kill -0 "$new_pid" 2>/dev/null; then
        Q2_PID=$new_pid
        echo "[kmonad] Q2 started (PID $Q2_PID) on $device"
        return 0
    else
        echo "[kmonad] Q2 kmonad failed to start — check $Q2_LOG"
        Q2_PID=""
        return 1
    fi
}

stop_q2() {
    if [ -n "$Q2_PID" ] && kill -0 "$Q2_PID" 2>/dev/null; then
        kill "$Q2_PID" 2>/dev/null
        wait "$Q2_PID" 2>/dev/null
    fi
    pkill -f "kmonad.*q2-runtime" 2>/dev/null
    Q2_PID=""
    echo "[kmonad] Q2 stopped"
}

cleanup() {
    echo "[kmonad] Shutting down..."
    [ -n "$LAPTOP_PID" ] && kill "$LAPTOP_PID" 2>/dev/null
    [ -n "$Q2_PID" ] && kill "$Q2_PID" 2>/dev/null
    pkill -f "kmonad.*laptop.kbd" 2>/dev/null
    pkill -f "kmonad.*q2-runtime" 2>/dev/null
    rm -f "$DAEMON_PID" "$Q2_RUNTIME"
    exit 0
}

do_status() {
    echo -n "Daemon: "
    if [ -f "$DAEMON_PID" ] && kill -0 "$(cat "$DAEMON_PID")" 2>/dev/null; then
        echo "running (PID $(cat "$DAEMON_PID"))"
    else
        echo "stopped"
    fi
    echo -n "Laptop: "
    if pgrep -f "kmonad.*laptop.kbd" > /dev/null 2>&1; then
        echo "running (PID $(pgrep -f 'kmonad.*laptop.kbd'))"
    else
        echo "stopped"
    fi
    echo -n "Q2:     "
    if pgrep -f "kmonad.*q2-runtime" > /dev/null 2>&1; then
        echo "running (PID $(pgrep -f 'kmonad.*q2-runtime'))"
    else
        echo "stopped"
    fi
}

do_stop() {
    if [ -f "$DAEMON_PID" ]; then
        local pid
        pid=$(cat "$DAEMON_PID")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping daemon (PID $pid)..."
            kill "$pid"
            sleep 0.5
        fi
        rm -f "$DAEMON_PID"
    fi
    pkill -f "kmonad.*laptop.kbd" 2>/dev/null
    pkill -f "kmonad.*q2-runtime" 2>/dev/null
    rm -f "$Q2_RUNTIME"
    echo "All stopped."
}

run_loop() {
    trap cleanup SIGTERM SIGINT SIGHUP

    pkill -f "kmonad.*laptop.kbd" 2>/dev/null
    pkill -f "kmonad.*q2-runtime" 2>/dev/null
    sleep 0.5

    start_laptop
    start_q2 2>/dev/null

    while true; do
        sleep 2

        # Restart laptop if it died
        if [ -n "$LAPTOP_PID" ] && ! kill -0 "$LAPTOP_PID" 2>/dev/null; then
            echo "[kmonad] Laptop kmonad died, restarting..."
            sleep 0.5
            start_laptop
        fi

        # Check Q2
        if find_q2_device > /dev/null 2>&1; then
            if [ -n "$Q2_PID" ] && ! kill -0 "$Q2_PID" 2>/dev/null; then
                # Process died but device shows — replug. Wait for full USB reinit.
                echo "[kmonad] Q2 kmonad died, waiting 4s for device to reinit..."
                Q2_PID=""
                sleep 4
                start_q2 2>/dev/null
            elif [ -z "$Q2_PID" ]; then
                start_q2 2>/dev/null
            fi
        else
            if [ -n "$Q2_PID" ]; then
                stop_q2
            fi
        fi
    done
}

case "${1:-}" in
    daemon)
        do_stop 2>/dev/null
        run_loop &
        echo $! > "$DAEMON_PID"
        echo "Daemon started (PID $!)"
        ;;
    stop)
        do_stop
        ;;
    status)
        do_status
        ;;
    *)
        do_stop 2>/dev/null
        echo $$ > "$DAEMON_PID"
        run_loop
        ;;
esac
