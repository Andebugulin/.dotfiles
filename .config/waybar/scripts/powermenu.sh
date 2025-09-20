#!/bin/bash
# Simple power menu script using rofi

entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

selected=$(echo -e $entries | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/powermenu.rasi)

case $selected in
    Lock)
        swaylock -f --image "~/Media/wallpapers/cool_girl_lemonade.png" --clock --indicator --indicator-radius 100 --indicator-thickness 7 --ring-color e67300 --key-hl-color cc3300 --line-color 00000000 --inside-color 00000088 --separator-color 00000000
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
esac