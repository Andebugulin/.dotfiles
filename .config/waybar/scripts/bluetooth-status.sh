#!/bin/bash

# Check if Bluetooth is powered
powered=$(bluetoothctl show | grep "Powered: yes" | wc -l)

# Check if there are any connected devices
connected=$(bluetoothctl info | grep "Connected: yes" | wc -l)

if [ "$powered" -eq 0 ]; then
    echo "" # Bluetooth off icon
elif [ "$connected" -eq 0 ]; then
    echo "" # Bluetooth on but not connected icon
else
    echo "" # Bluetooth connected icon
fi
