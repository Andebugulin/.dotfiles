#!/bin/bash

# Check current VPN status
status=$(mullvad status 2>/dev/null)

if echo "$status" | grep -q "Connected"; then
    # Disconnect from VPN
    mullvad disconnect
    notify-send "Mullvad VPN" "Disconnecting from VPN..." -i network-vpn-disconnected
else
    # Connect to VPN
    mullvad connect
    notify-send "Mullvad VPN" "Connecting to VPN..." -i network-vpn
fi

# Signal waybar to refresh (signal 8 as defined in your config)
pkill -RTMIN+8 waybar