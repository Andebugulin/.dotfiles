#!/bin/bash
# install-kmonad-configs.sh
# Sets up dual kmonad configs for laptop + Keychron Q2
# Run: chmod +x install-kmonad-configs.sh && ./install-kmonad-configs.sh

set -e
KMONAD_DIR="$HOME/.config/kmonad"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME="$(whoami)"

echo "=== Installing kmonad dual-keyboard setup ==="

# 1. Backup existing config
if [ -f "$KMONAD_DIR/config.kbd" ]; then
    echo "Backing up existing config → config.kbd.bak"
    cp "$KMONAD_DIR/config.kbd" "$KMONAD_DIR/config.kbd.bak"
fi

# 2. Copy configs
echo "Copying configs to $KMONAD_DIR/"
cp "$SCRIPT_DIR/laptop.kbd" "$KMONAD_DIR/"
cp "$SCRIPT_DIR/q2.kbd" "$KMONAD_DIR/"
cp "$SCRIPT_DIR/kmonad-start.sh" "$KMONAD_DIR/"
chmod +x "$KMONAD_DIR/kmonad-start.sh"

# 3. Install udev rule
echo "Installing udev rule (needs sudo)..."
sed "s/YOUR_USERNAME/$USERNAME/g" "$SCRIPT_DIR/99-keychron-q2-kmonad.rules" | \
    sudo tee /etc/udev/rules.d/99-keychron-q2-kmonad.rules > /dev/null
sudo udevadm control --reload-rules

# 4. Remind about hyprland config
echo ""
echo "=== Done! ==="
echo ""
echo "Now update ~/.config/hypr/hyprland.conf:"
echo "  Replace:  exec-once = kmonad ~/.config/kmonad/config.kbd"
echo "  With:     exec-once = ~/.config/kmonad/kmonad-start.sh start"
echo ""
echo "Then restart hyprland or run:"
echo "  ~/.config/kmonad/kmonad-start.sh restart"
echo ""
echo "Check status anytime with:"
echo "  ~/.config/kmonad/kmonad-start.sh status"
