#!/bin/bash

# Pomodoro timer for waybar - unified, with scrollable durations.
# Usage:
#   pomodoro.sh pomodoro [click|scroll-up|scroll-down]
#   pomodoro.sh break    [click|scroll-up|scroll-down]

MODULE="${1:-pomodoro}"
ACTION="${2:-update}"

# --- Configuration ----------------------------------------------------------

STATE_DIR="$HOME/.cache/pomodoro"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/state"
LOCK_FILE="$STATE_DIR/transition.lock"

WORK_COMPLETE_SOUND="/home/andrei/Media/sounds/complete-pomodoro.mp3"
BREAK_COMPLETE_SOUND="/home/andrei/Media/sounds/back-to-work-pomodoro.mp3"

DEFAULT_WORK_TIME=25
DEFAULT_BREAK_TIME=5
MIN_WORK=1
MAX_WORK=180   # 3 hours
MIN_BREAK=1
MAX_BREAK=60

WORK_ICON="󱎫"
BREAK_ICON="󰭹"

# --- State handling ---------------------------------------------------------

if [ -f "$STATE_FILE" ]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
fi
STATE=${STATE:-idle}
END_TIME=${END_TIME:-0}
WORK_TIME=${WORK_TIME:-$DEFAULT_WORK_TIME}
BREAK_TIME=${BREAK_TIME:-$DEFAULT_BREAK_TIME}

save_state() {
    cat > "$STATE_FILE" <<EOF
STATE=$STATE
END_TIME=$END_TIME
WORK_TIME=$WORK_TIME
BREAK_TIME=$BREAK_TIME
EOF
}

# --- Helpers ----------------------------------------------------------------

play_sound() {
    local f=$1
    [ -f "$f" ] || return
    (mpv --no-terminal "$f" &>/dev/null ||
     mplayer "$f" &>/dev/null ||
     ffplay -nodisp -autoexit "$f" &>/dev/null ||
     paplay "$f" &>/dev/null) &
}

format_time() {
    local s=$1
    printf "%02d:%02d" $((s / 60)) $((s % 60))
}

adjust() {
    local current=$1 dir=$2 min=$3 max=$4
    if [ "$dir" = "up" ]; then
        current=$((current + 1))
        [ "$current" -gt "$max" ] && current=$max
    else
        current=$((current - 1))
        [ "$current" -lt "$min" ] && current=$min
    fi
    echo "$current"
}

# Auto-transition states. Locked so two waybar polls can't double-fire.
check_timer() {
    (
        flock -n 9 || exit 0
        # Re-read state inside the lock to avoid races.
        # shellcheck disable=SC1090
        source "$STATE_FILE" 2>/dev/null
        STATE=${STATE:-idle}
        END_TIME=${END_TIME:-0}
        WORK_TIME=${WORK_TIME:-$DEFAULT_WORK_TIME}
        BREAK_TIME=${BREAK_TIME:-$DEFAULT_BREAK_TIME}

        if [ "$STATE" != "idle" ] && [ "$(date +%s)" -ge "$END_TIME" ]; then
            NOW=$(date +%s)
            EXPIRED_BY=$((NOW - END_TIME))

            if [ "$EXPIRED_BY" -gt 60 ]; then
                # Stale state (e.g. after reboot) - silently reset.
                STATE=idle
                END_TIME=0
            elif [ "$STATE" = "working" ]; then
                notify-send "Pomodoro" "Work session done! Time for a break." -i clock
                play_sound "$WORK_COMPLETE_SOUND"
                STATE=break
                END_TIME=$((NOW + BREAK_TIME * 60))
            else
                notify-send "Pomodoro" "Break over! Ready for the next session?" -i clock
                play_sound "$BREAK_COMPLETE_SOUND"
                STATE=idle
                END_TIME=0
            fi
            save_state
        fi
    ) 9>"$LOCK_FILE"

    # Reload latest state in caller scope.
    # shellcheck disable=SC1090
    source "$STATE_FILE" 2>/dev/null
    STATE=${STATE:-idle}
    END_TIME=${END_TIME:-0}
    WORK_TIME=${WORK_TIME:-$DEFAULT_WORK_TIME}
    BREAK_TIME=${BREAK_TIME:-$DEFAULT_BREAK_TIME}
}

# --- Actions ----------------------------------------------------------------

case "$ACTION" in
    click)
        if [ "$MODULE" = "pomodoro" ]; then
            case "$STATE" in
                idle)
                    STATE=working
                    END_TIME=$(( $(date +%s) + WORK_TIME * 60 ))
                    save_state
                    notify-send "Pomodoro" "Work session started (${WORK_TIME} min)" -i clock
                    ;;
                working)
                    STATE=idle
                    END_TIME=0
                    save_state
                    notify-send "Pomodoro" "Work session cancelled" -i clock
                    ;;
                break)
                    STATE=idle
                    END_TIME=0
                    save_state
                    notify-send "Pomodoro" "Break skipped" -i clock
                    ;;
            esac
        else
            # Break module: click skips a running break.
            if [ "$STATE" = "break" ]; then
                STATE=idle
                END_TIME=0
                save_state
                notify-send "Pomodoro" "Break skipped" -i clock
            fi
        fi
        exit 0
        ;;
    scroll-up)
        if [ "$MODULE" = "pomodoro" ]; then
            WORK_TIME=$(adjust "$WORK_TIME" up "$MIN_WORK" "$MAX_WORK")
        else
            BREAK_TIME=$(adjust "$BREAK_TIME" up "$MIN_BREAK" "$MAX_BREAK")
        fi
        save_state
        exit 0
        ;;
    scroll-down)
        if [ "$MODULE" = "pomodoro" ]; then
            WORK_TIME=$(adjust "$WORK_TIME" down "$MIN_WORK" "$MAX_WORK")
        else
            BREAK_TIME=$(adjust "$BREAK_TIME" down "$MIN_BREAK" "$MAX_BREAK")
        fi
        save_state
        exit 0
        ;;
esac

# --- Update path: check timer, then emit JSON for waybar -------------------

check_timer

if [ "$MODULE" = "pomodoro" ]; then
    if [ "$STATE" = "working" ]; then
        remaining=$(( END_TIME - $(date +%s) ))
        [ "$remaining" -lt 0 ] && remaining=0
        disp=$(format_time "$remaining")
        echo "{\"text\":\"$WORK_ICON $disp\",\"class\":\"working\",\"tooltip\":\"Working — $disp remaining\\nClick to cancel\"}"
    else
        echo "{\"text\":\"$WORK_ICON ${WORK_TIME}m\",\"class\":\"idle\",\"tooltip\":\"Pomodoro: ${WORK_TIME} min\\nClick to start · Scroll to adjust (${MIN_WORK}–${MAX_WORK} min)\"}"
    fi
else
    if [ "$STATE" = "break" ]; then
        remaining=$(( END_TIME - $(date +%s) ))
        [ "$remaining" -lt 0 ] && remaining=0
        disp=$(format_time "$remaining")
        echo "{\"text\":\"$BREAK_ICON $disp\",\"class\":\"break\",\"tooltip\":\"Break — $disp remaining\\nClick to skip\"}"
    else
        echo "{\"text\":\"$BREAK_ICON ${BREAK_TIME}m\",\"class\":\"idle\",\"tooltip\":\"Break: ${BREAK_TIME} min\\nScroll to adjust (${MIN_BREAK}–${MAX_BREAK} min)\"}"
    fi
fi