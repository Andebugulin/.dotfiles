#!/bin/bash

# Define source and destination directories
DOTFILES_DIR="/home/andrei/vscoding/.dotfiles/.config"
CONFIG_DIR="/home/andrei/.config"
CODE_USER_DIR="/home/andrei/.config/Code/User/sync"
SOCIAL_BLOCKER_FILE="/home/andrei/social-blocker.sh"

# List of directories to sync
DIRS_TO_SYNC=(
    "$CONFIG_DIR/hypr"
    "$CONFIG_DIR/kmonad"
    "$CONFIG_DIR/swayidle"
    "$CONFIG_DIR/waybar"
    "$CONFIG_DIR/archblocker"
    "$CONFIG_DIR/kitty"
    "$CODE_USER_DIR/keybindings"
)

# Sync function
sync_dotfiles() {
    echo "Starting dotfiles synchronization..."
    
    for src in "${DIRS_TO_SYNC[@]}"; do
        # Get the last part of the source directory name (e.g., "hypr", "kmonad")
        base_name=$(basename "$src")
        
        # Construct the destination path
        dest="$DOTFILES_DIR/$base_name"

        echo "Syncing $src to $dest..."
        
        # Create destination directory if it doesn't exist
        mkdir -p "$dest"
        
        # Copy the contents of the source directory to the destination
        cp -r "$src/"* "$dest/"
    done

    echo "Dotfiles synchronization complete!"
}

# Run the sync function
sync_dotfiles

cp "$SOCIAL_BLOCKER_FILE" "$DOTFILES_DIR"