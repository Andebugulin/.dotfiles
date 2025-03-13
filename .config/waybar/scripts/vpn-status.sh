#!/bin/bash

# Check if ProtonVPN is connected using the ProtonVPN CLI
if protonvpn status 2>/dev/null | grep -q "Connected"; then
    # Get VPN details
    vpn_status=$(protonvpn status 2>/dev/null)
    server=$(echo "$vpn_status" | grep "Server:" | cut -d ':' -f2- | xargs)
    country=$(echo "$vpn_status" | grep "Country:" | cut -d ':' -f2- | xargs)
    
    if [[ -n "$server" && -n "$country" ]]; then
        tooltip="Connected to $server ($country)"
    elif [[ -n "$server" ]]; then
        tooltip="Connected to $server"
    else
        tooltip="Connected to ProtonVPN"
    fi
    
    # Use a filled shield icon for connected state
    echo '{"text": "󰌾", "class": "connected", "tooltip": "'"$tooltip"'"}'
else
    # Handle the reconnection scenario
    if protonvpn status 2>/dev/null | grep -q "Could not reach"; then
        tooltip="Connection issue - try reconnecting"
        echo '{"text": "󱘖", "class": "error", "tooltip": "'"$tooltip"'"}'
    else
        # Standard disconnected state
        echo '{"text": "󰌿", "class": "disconnected", "tooltip": "Not connected"}'
    fi
fi