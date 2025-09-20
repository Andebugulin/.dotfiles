#!/bin/bash

# Determine which timer to use based on first argument
TIMER_TYPE="${1:-short}"  # Default to short if no argument

# Path for storing pomodoro state
POMODORO_STATE_DIR="$HOME/.cache/pomodoro"
mkdir -p "$POMODORO_STATE_DIR"

POMODORO_STATE_FILE="$POMODORO_STATE_DIR/pomodoro_state_$TIMER_TYPE"
POMODORO_PID_FILE="$POMODORO_STATE_DIR/pomodoro_pid_$TIMER_TYPE"

# Sound files - MP3 format
WORK_COMPLETE_SOUND="/home/andrei/Media/sounds/complete-pomodoro.mp3"
BREAK_COMPLETE_SOUND="/home/andrei/Media/sounds/back-to-work-pomodoro.mp3"

# Timer configurations
if [ "$TIMER_TYPE" = "short" ]; then
    DEFAULT_WORK_TIME=25  # minutes
    DEFAULT_BREAK_TIME=5  # minutes
    TIMER_ICON="󱑖"
    WORK_ICON="󱎫"
    BREAK_ICON="󰭹"
    TIMER_NAME="Short"
elif [ "$TIMER_TYPE" = "long" ]; then
    DEFAULT_WORK_TIME=40  # minutes
    DEFAULT_BREAK_TIME=10  # minutes
    TIMER_ICON="󰥔"
    WORK_ICON="󱎬"
    BREAK_ICON="󰭺"
    TIMER_NAME="Long"
else
    echo "Invalid timer type: $TIMER_TYPE"
    exit 1
fi

# Get current state or set default
if [ -f "$POMODORO_STATE_FILE" ]; then
  source "$POMODORO_STATE_FILE"
else
  # Initialize with defaults
  echo "STATE=idle" > "$POMODORO_STATE_FILE"
  echo "END_TIME=0" >> "$POMODORO_STATE_FILE"
  echo "WORK_TIME=$DEFAULT_WORK_TIME" >> "$POMODORO_STATE_FILE"
  echo "BREAK_TIME=$DEFAULT_BREAK_TIME" >> "$POMODORO_STATE_FILE"
  source "$POMODORO_STATE_FILE"
fi

# Function to play sound
play_sound() {
  local sound_file=$1
  if [ -f "$sound_file" ]; then
    # Try mpv first (best MP3 support)
    mpv "$sound_file" &>/dev/null || \
    # Try mplayer as fallback
    mplayer "$sound_file" &>/dev/null || \
    # Try ffplay as another option
    ffplay -nodisp -autoexit "$sound_file" &>/dev/null || \
    # Last resort - try paplay but it might not work with MP3
    paplay "$sound_file" &>/dev/null || \
    # Terminal bell if everything fails
    echo -e "\a"
  else
    # Sound file not found
    notify-send "Pomodoro ($TIMER_NAME)" "Sound file not found: $sound_file" -i error
    echo -e "\a" # Terminal bell
  fi
}

# Function to format time remaining
format_time_remaining() {
  local seconds=$1
  local minutes=$((seconds / 60))
  local remaining_seconds=$((seconds % 60))
  printf "%02d:%02d" $minutes $remaining_seconds
}

# Function to start a timer
start_timer() {
  local duration=$1  # in minutes
  local state=$2
  local end_time=$(($(date +%s) + duration * 60))
  
  # Save state
  echo "STATE=$state" > "$POMODORO_STATE_FILE"
  echo "END_TIME=$end_time" >> "$POMODORO_STATE_FILE"
  echo "WORK_TIME=$WORK_TIME" >> "$POMODORO_STATE_FILE"
  echo "BREAK_TIME=$BREAK_TIME" >> "$POMODORO_STATE_FILE"
  
  # Notify user
  if [ "$state" = "working" ]; then
    notify-send "Pomodoro ($TIMER_NAME)" "Work session started ($duration minutes)" -i clock
  else
    notify-send "Pomodoro ($TIMER_NAME)" "Break started ($duration minutes)" -i clock
  fi
}

# Check if we need to switch states automatically
check_timer() {
  # If we're not idle and the timer is up
  if [ "$STATE" != "idle" ] && [ $(date +%s) -ge $END_TIME ]; then
    if [ "$STATE" = "working" ]; then
      # Work time is over, start break
      notify-send "Pomodoro ($TIMER_NAME)" "Work session finished! Take a break." -i clock
      play_sound "$WORK_COMPLETE_SOUND"
      start_timer $BREAK_TIME "break"
    else
      # Break time is over, go back to idle
      notify-send "Pomodoro ($TIMER_NAME)" "Break finished! Ready for next session?" -i clock
      play_sound "$BREAK_COMPLETE_SOUND"
      echo "STATE=idle" > "$POMODORO_STATE_FILE"
      echo "END_TIME=0" >> "$POMODORO_STATE_FILE"
      echo "WORK_TIME=$WORK_TIME" >> "$POMODORO_STATE_FILE"
      echo "BREAK_TIME=$BREAK_TIME" >> "$POMODORO_STATE_FILE"
    fi
  fi
}

# Handle click action
handle_click() {
  case "$STATE" in
    idle)
      # Start work session
      start_timer $WORK_TIME "working"
      ;;
    working)
      # Cancel current session
      echo "STATE=idle" > "$POMODORO_STATE_FILE"
      echo "END_TIME=0" >> "$POMODORO_STATE_FILE"
      echo "WORK_TIME=$WORK_TIME" >> "$POMODORO_STATE_FILE"
      echo "BREAK_TIME=$BREAK_TIME" >> "$POMODORO_STATE_FILE"
      notify-send "Pomodoro ($TIMER_NAME)" "Work session cancelled" -i clock
      ;;
    break)
      # Cancel break
      echo "STATE=idle" > "$POMODORO_STATE_FILE"
      echo "END_TIME=0" >> "$POMODORO_STATE_FILE"
      echo "WORK_TIME=$WORK_TIME" >> "$POMODORO_STATE_FILE"
      echo "BREAK_TIME=$BREAK_TIME" >> "$POMODORO_STATE_FILE"
      notify-send "Pomodoro ($TIMER_NAME)" "Break cancelled" -i clock
      ;;
  esac
}

# Check if we should handle a click
if [ "$2" = "click" ]; then
  handle_click
  exit 0
fi

# Check if we need to update state
check_timer

# Calculate time remaining if not idle
if [ "$STATE" != "idle" ]; then
  time_remaining=$((END_TIME - $(date +%s)))
  if [ $time_remaining -lt 0 ]; then
    time_remaining=0
  fi
  time_display=$(format_time_remaining $time_remaining)
else
  time_display="$TIMER_ICON"
fi

# Output for waybar
case "$STATE" in
  idle)
    echo "{\"text\": \"$time_display\", \"class\": \"idle-$TIMER_TYPE\", \"tooltip\": \"$TIMER_NAME Pomodoro: Click to start ${WORK_TIME}min work session\"}"
    ;;
  working)
    echo "{\"text\": \"$WORK_ICON $time_display\", \"class\": \"working-$TIMER_TYPE\", \"tooltip\": \"$TIMER_NAME Pomodoro - Working: $time_display remaining. Click to cancel.\"}"
    ;;
  break)
    echo "{\"text\": \"$BREAK_ICON $time_display\", \"class\": \"break-$TIMER_TYPE\", \"tooltip\": \"$TIMER_NAME Pomodoro - Break: $time_display remaining. Click to skip.\"}"
    ;;
esac