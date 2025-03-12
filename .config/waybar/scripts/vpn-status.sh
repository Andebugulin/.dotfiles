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
    
    echo '{"text": "󰌾 VPN", "class": "connected", "tooltip": "'"$tooltip"'"}'
else
    echo '{"text": "󰌿 VPN", "class": "disconnected", "tooltip": "Not connected"}'
fi