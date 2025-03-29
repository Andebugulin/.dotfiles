#!/bin/bash

# Define source and destination directories
DOTFILES_DIR="/home/andrei/vscoding/.dotfiles/.config"
CONFIG_DIR="/home/andrei/.config"
CODE_USER_DIR="/home/andrei/.config/Code/User/sync"
SOCIAL_BLOCKER_FILE="/home/andrei/social-blocker.sh"

# List of directories to restore
DIRS_TO_RESTORE=(
    "hypr"
    "kmonad"
    "swayidle"
    "waybar"
)

# Restore function
restore_dotfiles() {
    echo "Starting dotfiles restoration..."
    
    # Restore main config directories
    for dir in "${DIRS_TO_RESTORE[@]}"; do
        # Construct source and destination paths
        src="$DOTFILES_DIR/$dir"
        dest="$CONFIG_DIR/$dir"
        
        echo "Restoring $src to $dest..."
        
        # Create destination directory if it doesn't exist
        mkdir -p "$dest"
        
        # Copy the contents of the source directory to the destination
        cp -r "$src/"* "$dest/"
    done
    
    # Restore VS Code keybindings
    echo "Restoring VS Code keybindings..."
    mkdir -p "$CODE_USER_DIR/keybindings"
    cp -r "$DOTFILES_DIR/keybindings/"* "$CODE_USER_DIR/keybindings/"
    
    # Restore social blocker script
    echo "Restoring social blocker script..."
    cp "$DOTFILES_DIR/social-blocker.sh" "$SOCIAL_BLOCKER_FILE"
    chmod +x "$SOCIAL_BLOCKER_FILE"
    
    echo "Dotfiles restoration complete!"
}

# Run the restore function
restore_dotfiles