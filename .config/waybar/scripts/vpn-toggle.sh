#!/bin/bash

# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
    # If not run with sudo, re-run with pkexec/sudo
    if command -v pkexec &> /dev/null; then
        pkexec "$0" "$@"
    else
        sudo "$0" "$@"
    fi
    exit $?
fi

# Check if ProtonVPN is connected using the ProtonVPN CLI
if protonvpn status 2>/dev/null | grep -q "Connected"; then
    # Disconnect from VPN
    protonvpn disconnect
    # Wait a bit for the disconnection to complete
    sleep 2
    notify-send "ProtonVPN" "Disconnected from VPN" -i network-vpn-disconnected
else
    # Connect to ProtonVPN with quick connect
    protonvpn connect -f
    # Wait a bit for the connection to complete
    sleep 2
    notify-send "ProtonVPN" "Connected to fastest server" -i network-vpn
fi

# We remove this line, let waybar handle refreshing:
# exec ./vpn-status.sh