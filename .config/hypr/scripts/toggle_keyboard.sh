#!/bin/bash

STATE_FILE="/tmp/kb_disabled"

if [ -f "$STATE_FILE" ]; then
    hyprctl keyword input:kb-ignore-input false
    rm "$STATE_FILE"
else
    hyprctl keyword input:kb-ignore-input true
    touch "$STATE_FILE"
fi
