# .dotfiles Repository

A collection of configuration files for my Arch Linux + Hyprland setup.

## Features

- **Hyprland**: Customized bindings and tiling window manager configurations.
- **Swaylock & Swayidle**: Enhanced security and power efficiency.
- **Waybar**: Customized status bar for essential system information.
- **Kmonad**: Powerful custom keyboard remapping and keybindings.
- **VS Code Keybindings**: Customized keybindings for Visual Studio Code.
- **archblocker**: A script to edit hosts file for blocking web content, or getting rid of addictions on Arch Linux.
- **kitty**: Terminal emulator with custom configurations.


## Prerequisites

Install the following packages from the Arch repositories and AUR:

```bash
# Core packages
sudo pacman -S hyprland kitty waybar swayidle swaylock wofi wl-clipboard git

mkdir Downloads
cd Downloads
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si

# AUR packages (using yay)
yay -S kmonad visual-studio-code-bin
```

## Installation

1. Clone this repository:
   ```bash
   mkdir ~/vscoding
   git clone https://github.com/andebugulin/.dotfiles.git ~/vscoding/.dotfiles
   cd ~/vscoding/.dotfiles
   ```

2. Make the restoration script executable:
   ```bash
   chmod +x restore_dotfiles.sh
   ```

3. Run the restoration script to install the configurations:
   ```bash
   ./restore_dotfiles.sh
   ```

## Backup Your Changes

When you make changes to your configurations, use the sync script to back them up:

```bash
./sync_dotfiles.sh
```

## Customization

Feel free to modify any of the configuration files to suit your needs. The main configuration files are located in the `.config` directory.

## Contributions

Contributions and suggestions are welcome! Please feel free to open pull requests for enhancements.

## Troubleshooting

- If you encounter permission issues, make sure the scripts are executable with `chmod +x *.sh`
- Ensure all required packages are installed before running the restoration script
- Check the paths in the scripts if your directory structure differs from the default

## Acknowledgements

Thanks to the creators of Hyprland, Waybar, Kmonad, and all the other tools that make this configuration possible.

## License

Licensed under [MIT License](LICENSE).