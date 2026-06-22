# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository scope

This git repo is rooted at `~/.config/hypr` but also tracks changes in sibling directories:
- `../waybar/` — Waybar status bar (mocha theme)
- `../kmonad/` — KMonad keyboard remapping daemon

The active Hyprland config is `hyprland.conf`; keybindings are split into `bindings.conf` and sourced from there.

## Applying changes

Hyprland reloads config automatically on file save for most settings. For keybindings and sourced files:
```bash
hyprctl reload
```

Restart Waybar after editing its config:
```bash
killall waybar && waybar -c ~/.config/waybar/mocha.jsonc -s ~/.config/waybar/mocha.css &
```

Restart the kmonad daemon after editing `.kbd` files:
```bash
~/.config/kmonad/kmonad-daemon.sh stop && ~/.config/kmonad/kmonad-daemon.sh
```

Check kmonad daemon status:
```bash
~/.config/kmonad/kmonad-daemon.sh status
```

## Architecture

### Hyprland (`hyprland.conf` + `bindings.conf`)

- Monitor: `eDP-1` at 1920×1080@60, 10-bit color.
- Layout: dwindle with no inner gaps, 1px outer gap, rounded corners.
- Keybind modifier pattern: most app/WM actions use `SUPER+SHIFT+ALT+<key>` (triple-chord) to avoid conflicts with kmonad's `syms` layer which emits `M-S-A-<key>` combos for Hyprland dispatcher calls.
- `bindings.conf` is sourced by `hyprland.conf`; all keybinds live there.
- Gestures use the `gesture` directive (not the deprecated `gestures {}` block): 3-finger horizontal swipe switches workspaces, 3-finger up/down toggles `special:scratch`.

### KMonad (`~/.config/kmonad/`)

Two simultaneous kmonad instances managed by `kmonad-daemon.sh`:

- **laptop.kbd** — targets `/dev/input/by-path/platform-i8042-serio-0-event-kbd` (hardcoded).
- **q2.kbd** — template file; the literal string `KMONAD_Q2_DEVICE` is replaced at runtime with the detected `/dev/input/by-id/` path for the Keychron Q2. The resolved config is written to `/tmp/kmonad-q2-runtime.kbd`.

`kmonad-daemon.sh` is the preferred entrypoint (replaces `kmonad-start.sh`). It polls every 2 s for hot-plug events and auto-restarts crashed instances. `kmonad-start.sh` is the older per-command script still invoked by the udev rule.

Shared layer design for both keyboards:
- `caps` → `@sym`: tap = `esc`, hold = `syms` layer (sends `M-S-A-<key>` combos that Hyprland intercepts).
- `lalt` → `@lalt`: tap = `lalt`, hold = `cursor` layer (hjkl → arrow keys).
- `fn` layer (Q2 only, held via `home` key): top row becomes F-keys, `@lock` enters the `locked` layer (all keys blocked except `@unlock` = `fn` position).

### Waybar (`~/.config/waybar/`)

Active config: `mocha.jsonc` + `mocha.css`. Started via `exec =` in `hyprland.conf` (not `exec-once`), so it relaunches on every `hyprctl reload`. `to_mocha.sh` kills waybar, starts it, and also randomises the wallpaper via `swaybg`.

Custom modules poll scripts in `~/.config/waybar/scripts/`:
- `pomodoro.sh` — pomodoro/break timer, returns JSON, interval 1 s.
- `workspace-app-icons.sh` — per-workspace app icon display in the center clock/workspace toggle.
- `vpn-status.sh` / `bluetooth-status.sh` / `dunst-toggle.sh` — status indicators.

### Scripts (`scripts/`)

- `volume-control.sh {up|down|toggle}` — pactl-based, caps at 150%.
- `toggle_keyboard.sh` — toggles `input:kb-ignore-input` via state file `/tmp/kb_disabled`.
- `inactive_lock.sh` — swayidle rule: turns off display if swaylock is running; locks before sleep with swaylock blur effect.
