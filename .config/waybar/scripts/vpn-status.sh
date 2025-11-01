#!/bin/bash

# Check Mullvad VPN connection status
status=$(mullvad status 2>/dev/null)

if echo "$status" | grep -q "Connected"; then
    # Extract server and location info
    server=$(echo "$status" | grep -oP '(?<=to )[^ ]+' | head -1)
    location=$(echo "$status" | grep -oP '(?<=in )[^\n]+' | head -1)
    
    if [[ -n "$location" ]]; then
        tooltip="Connected to $location"
        if [[ -n "$server" ]]; then
            tooltip="$tooltip ($server)"
        fi
    elif [[ -n "$server" ]]; then
        tooltip="Connected to $server"
    else
        tooltip="Connected to Mullvad VPN"
    fi
    
    # Connected state with filled shield icon
    echo '{"text": "󰌾", "class": "connected", "tooltip": "'"$tooltip"'"}'
elif echo "$status" | grep -q "Connecting"; then
    # Connecting state
    echo '{"text": "󰦞", "class": "connecting", "tooltip": "Connecting to Mullvad VPN..."}'
elif echo "$status" | grep -q "Disconnecting"; then
    # Disconnecting state
    echo '{"text": "󰦞", "class": "disconnecting", "tooltip": "Disconnecting from Mullvad VPN..."}'
elif echo "$status" | grep -q "Blocked"; then
    # Kill switch is blocking
    echo '{"text": "󰌿", "class": "blocked", "tooltip": "Disconnected (Kill switch active)"}'
else
    # Standard disconnected state
    echo '{"text": "󰌿", "class": "disconnected", "tooltip": "Not connected - Click to connect"}'
fi