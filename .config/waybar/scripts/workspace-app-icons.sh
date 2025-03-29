#!/bin/bash

# Log unmatched applications for future improvements
log_unmatched() {
  local class="$1"
  echo "$(date): Unmatched class: $class" >> ~/.config/waybar/unmatched_apps.log
}

# Function to get the appropriate icon for a window class
get_icon() {
  local window_class="$1"
  local window_title="$2"
  
  # Convert to lowercase for more reliable matching
  local lc_class=$(echo "$window_class" | tr '[:upper:]' '[:lower:]')
  local lc_title=$(echo "$window_title" | tr '[:upper:]' '[:lower:]')
  
  # First try to match specific applications by class
  case "$lc_class" in
    # Terminal emulators
    *"kitty"*|*"alacritty"*|*"terminal"*|*"konsole"*|*"xterm"*|*"terminator"*|*"xfce4-terminal"*|*"foot"*|*"urxvt"*|*"st"*|*"gnome-terminal"*) 
      echo "󰆍" ;;
    
    # Browsers
    *"firefox"*|*"librewolf"*|*"icecat"*|*"waterfox"*) 
      echo "󰈹" ;;
    *"chromium"*|*"chrome"*) 
      echo "󰊯" ;;
    *"brave-browser"*|*"brave"*) 
      echo "󰗃" ;;
    *"vivaldi"*) 
      echo "󰖟" ;;
    *"opera"*) 
      echo "󰀹" ;;
    *"microsoft-edge"*|*"msedge"*) 
      echo "󰇩" ;;
    *"epiphany"*|*"gnome-web"*) 
      echo "󰈹" ;;
    *"tor-browser"*) 
      echo "󰈹" ;;
    *"qutebrowser"*) 
      echo "󰖟" ;;
    
    # Code editors / IDEs
    *"code"*|*"code-oss"*|*"vscodium"*) 
      echo "󰨞" ;;
    *"sublime"*|*"subl"*) 
      echo "󰇮" ;;
    *"atom"*) 
      echo "󰂙" ;;
    *"jetbrains"*|*"idea"*|*"studio"*|*"intellij"*) 
      echo "󰮭" ;;
    *"pycharm"*) 
      echo "󰌠" ;;
    *"phpstorm"*) 
      echo "󰌠" ;;
    *"webstorm"*) 
      echo "󰌠" ;;
    *"clion"*) 
      echo "󰮭" ;;
    *"neovide"*|*"gvim"*|*"vim"*) 
      echo "󰕙" ;;
    *"emacs"*) 
      echo "󰘼" ;;
    *"geany"*) 
      echo "󰇮" ;;
    *"arduino"*) 
      echo "󰢩" ;;
    
    # File managers
    *"thunar"*|*"nautilus"*|*"dolphin"*|*"pcmanfm"*|*"nemo"*|*"caja"*|*"krusader"*|*"ranger"*|*"spacefm"*) 
      echo "󰉋" ;;
    
    # Media
    *"spotify"*) 
      echo "󰓇" ;;
    *"mpv"*|*"vlc"*|*"totem"*|*"smplayer"*|*"mplayer"*) 
      echo "󰕼" ;;
    *"celluloid"*) 
      echo "󰎁" ;;
    *"clementine"*|*"rhythmbox"*|*"deadbeef"*|*"audacious"*|*"banshee"*|*"amarok"*|*"strawberry"*) 
      echo "󰎈" ;;
    *"audacity"*) 
      echo "󰎈" ;;
    
    # Communication
    *"discord"*) 
      echo "󰙯" ;;
    *"telegram"*) 
      echo "󰔁" ;;
    *"whatsapp"*) 
      echo "󰖣" ;;
    *"slack"*) 
      echo "󰒱" ;;
    *"element"*|*"riot"*) 
      echo "󰍦" ;;
    *"signal"*) 
      echo "󰭹" ;;
    *"thunderbird"*|*"mailspring"*|*"geary"*|*"evolution"*) 
      echo "󰇮" ;;
    *"skype"*) 
      echo "󰒱" ;;
    *"teams"*|*"microsoft teams"*) 
      echo "󰊻" ;;
    *"zoom"*) 
      echo "󰨆" ;;
    *"mumble"*) 
      echo "󰍬" ;;
    *"hexchat"*|*"xchat"*|*"konversation"*) 
      echo "󰍬" ;;
    
    # Graphics
    *"gimp"*) 
      echo "󰏘" ;;
    *"inkscape"*|*"krita"*) 
      echo "󱍔" ;;
    *"blender"*) 
      echo "󰂫" ;;
    *"darktable"*) 
      echo "󰄄" ;;
    *"digikam"*) 
      echo "󰄄" ;;
    *"gwenview"*|*"eog"*|*"gthumb"*|*"shotwell"*|*"viewnior"*) 
      echo "󰋩" ;;
    *"kdenlive"*|*"openshot"*|*"pitivi"*|*"shotcut"*) 
      echo "󰕼" ;;
    
    # Office/Productivity
    *"libreoffice"*|*"soffice"*|*"writer"*) 
      echo "󰈙" ;;
    *"calc"*|*"gnumeric"*) 
      echo "󰧮" ;;
    *"okular"*|*"zathura"*|*"evince"*|*"mupdf"*|*"xreader"*|*"atril"*|*"qpdfview"*) 
      echo "󰈦" ;;
    *"calibre"*) 
      echo "󰂿" ;;
    *"obsidian"*|*"typora"*|*"joplin"*|*"marktext"*|*"notable"*) 
      echo "󱞁" ;;
    
    # Gaming
    *"steam"*) 
      echo "󰓓" ;;
    *"lutris"*|*"wine"*|*"bottles"*) 
      echo "󰊗" ;;
    *"heroic"*) 
      echo "󰊗" ;;
    *"minecraft"*) 
      echo "󰍳" ;;
    
    # System Tools
    *"gnome-system-monitor"*|*"htop"*|*"ksysguard"*) 
      echo "󰨇" ;;
    *"pavucontrol"*|*"pulseaudio"*) 
      echo "󰕾" ;;
    *"blueman"*|*"blueberry"*) 
      echo "󰂯" ;;
    *"gparted"*) 
      echo "󰋊" ;;
    *"vmware"*|*"virtualbox"*) 
      echo "󰢹" ;;
    *"virt-manager"*) 
      echo "󰢹" ;;
    *"baobab"*|*"filelight"*|*"disk-usage"*) 
      echo "󰋊" ;;
    
    # Try to match by window title if class doesn't match
    *)
      case "$lc_title" in
        *"firefox"*|*"librewolf"*) 
          echo "󰈹" ;;
        *"terminal"*|*"bash"*|*"zsh"*|*"fish"*) 
          echo "󰆍" ;;
        *"spotify"*) 
          echo "󰓇" ;;
        *"steam"*) 
          echo "󰓓" ;;
        *"libreoffice"*) 
          echo "󰈙" ;;
        *"vscode"*|*"visual studio code"*) 
          echo "󰨞" ;;
        *)
          # Log unmatched for future improvements
          log_unmatched "$window_class ($window_title)"
          echo "󰊠" ;;
      esac
      ;;
  esac
}

# Get active workspace
active_workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
if [[ -z "$active_workspace" ]]; then
  active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
fi

# Initialize arrays for workspace icons
declare -A workspace_icons
for i in {1..5}; do
  workspace_icons[$i]="󰧵"  # Default empty icon
done

# Store window information in a temporary file to avoid pipe subshell issues
windows_json=$(hyprctl clients -j)
echo "$windows_json" > /tmp/hypr_windows.json

# Process windows and collect icons for each workspace
declare -A workspace_app_icons
for i in {1..5}; do
  workspace_app_icons[$i]=""
done

# Process all windows
while read -r window; do
  window_workspace=$(echo "$window" | jq -r '.workspace.id')
  window_class=$(echo "$window" | jq -r '.class')
  window_title=$(echo "$window" | jq -r '.title')
  
  # Only process valid workspaces (1-5)
  if [[ "$window_workspace" =~ ^[1-5]$ ]]; then
    # Get icon for this window
    app_icon=$(get_icon "$window_class" "$window_title")
    
    # Add this icon to the workspace's app icons if not already present
    if [[ ! "${workspace_app_icons[$window_workspace]}" =~ "$app_icon" ]]; then
      workspace_app_icons[$window_workspace]+="$app_icon "
    fi
  fi
done < <(jq -c '.[]' /tmp/hypr_windows.json 2>/dev/null)

# Set workspace icons based on active apps
for i in {1..5}; do
  if [[ -n "${workspace_app_icons[$i]}" ]]; then
    # Trim trailing space
    workspace_app_icons[$i]="${workspace_app_icons[$i]% }"
    
    # Set icon based on apps
    workspace_icons[$i]="${workspace_app_icons[$i]}"
    
    # Highlight active workspace
    if [[ "$i" == "$active_workspace" ]]; then
      workspace_icons[$i]="<span color='#ab80d8'>${workspace_icons[$i]}</span>"
    fi
  else
    # Empty workspace
    if [[ "$i" == "$active_workspace" ]]; then
      workspace_icons[$i]="<span color='#ab80d8'>󰧵</span>"
    fi
  fi
done

# Build workspace display string
workspace_display=""
for i in {1..5}; do
  workspace_display="${workspace_display} ${workspace_icons[$i]} "
done

# Output JSON for Waybar
echo "{\"text\": \"$workspace_display\"}"