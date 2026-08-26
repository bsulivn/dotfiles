# dotfiles

My current macOS development environment, stored using paths relative to `$HOME`.

## Included

- Hyper key and modal window controls: Karabiner-Elements, `skhd`, and `yabai`
- Window appearance and command hints: JankyBorders and SketchyBar
- Neovim/LazyVim configuration, plugins, keymaps, and lockfile
- Shell startup files for zsh, bash, and tcsh
- Git and GitHub CLI preferences
- Ghostty, Zed, VS Code, and OpenCode settings
- Selected Codex and Claude agent configuration that contains no credentials or history

The Hyper layer maps Caps Lock to Command-Control-Option-Shift when held and Escape when tapped. See `.skhdrc` for focus, workspace, move, resize, fullscreen, float, balance, Ghostty, Raycast, and help bindings.

## macOS window-management dependencies

```sh
brew tap koekeishiya/formulae
brew tap felixkratz/formulae
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
brew install felixkratz/formulae/borders felixkratz/formulae/sketchybar
brew install neovim
brew install --cask karabiner-elements ghostty
```

After granting the required macOS Accessibility permissions, start `yabai`, `skhd`, and SketchyBar using their Homebrew service instructions. The external-display padding script contains this machine's display UUID; update `.config/yabai/update-display-padding.sh` when restoring to different hardware.

## Restoring

Clone the repository, review the diff against the destination machine, then copy or symlink the desired files to the matching paths under `$HOME`. Files under `Library/Application Support` intentionally mirror their native macOS locations.

## Safety

Authentication files, API credentials, histories, databases, logs, caches, backups, generated runtime state, and local-only settings are excluded. In particular, `.config/gh/hosts.yml`, `.codex/auth.json`, `.claude.json`, and shell/editor histories must never be committed.
