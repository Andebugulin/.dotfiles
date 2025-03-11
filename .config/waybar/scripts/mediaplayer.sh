#!/bin/bash
# Script for displaying currently playing media information

player_status=$(playerctl status 2> /dev/null)
if [[ "$player_status" == "Playing" ]]; then
    artist=$(playerctl metadata artist 2> /dev/null)
    title=$(playerctl metadata title 2> /dev/null)
    
    if [[ -n "$artist" && -n "$title" ]]; then
        # Limit length to prevent overflow
        if [[ ${#title} -gt 20 ]]; then
            title="${title:0:17}..."
        fi
        
        echo "{\"text\": \"󰎈 ${artist} - ${title}\", \"class\": \"playing\", \"tooltip\": \"${artist} - ${title}\"}"
    else
        echo "{\"text\": \"󰎆 Playing\", \"class\": \"playing\"}"
    fi
elif [[ "$player_status" == "Paused" ]]; then
    artist=$(playerctl metadata artist 2> /dev/null)
    title=$(playerctl metadata title 2> /dev/null)
    
    if [[ -n "$artist" && -n "$title" ]]; then
        # Limit length to prevent overflow
        if [[ ${#title} -gt 20 ]]; then
            title="${title:0:17}..."
        fi
        
        echo "{\"text\": \"󰏤 ${artist} - ${title}\", \"class\": \"paused\", \"tooltip\": \"${artist} - ${title}\"}"
    else
        echo "{\"text\": \"󰏤 Paused\", \"class\": \"paused\"}"
    fi
else
    echo "{\"text\": \"󰎇 No media\", \"class\": \"stopped\"}"
fi