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

## Homebrew dependencies

```sh
brew bundle install
```

`Brewfile` is generated with `brew bundle dump --force` and covers taps, formulae, casks, VS Code extensions, and the cargo/npm-installed CLI tools. Two things `brew bundle dump` gets wrong on its own, already fixed in the checked-in `Brewfile` (see the comments there):

- `yabai` and `skhd` don't reinstall from a plain re-dump — Homebrew doesn't mark them "installed on request" on this machine, so `brew bundle dump` silently drops them. They're pinned in explicitly.
- The `koekeishiya/formulae` tap actually resolves to `asmvik/homebrew-formulae.git`, a fork, not the upstream koekeishiya repo — and `asmvik/formulae` is tapped separately too, with its own conflicting `yabai`/`skhd`. The Brewfile uses the fully-qualified `koekeishiya/formulae/yabai` name to avoid the ambiguity. If you ever re-tap from scratch, tapping the plain name will *not* reproduce this setup — use the URL on the `tap` line.

Re-run `brew bundle dump --force` periodically to keep the file honest, then re-check the two fixes above before committing — a fresh dump will silently drop them again.

After granting the required macOS Accessibility permissions, start `yabai`, `skhd`, and SketchyBar using their Homebrew service instructions. The external-display padding script contains this machine's display UUID; update `.config/yabai/update-display-padding.sh` when restoring to different hardware.

## Restoring

Clone the repository, run `brew bundle install`, review the diff against the destination machine, then copy or symlink the desired files to the matching paths under `$HOME`. Files under `Library/Application Support` intentionally mirror their native macOS locations.

## Safety

Authentication files, API credentials, histories, databases, logs, caches, backups, generated runtime state, and local-only settings are excluded. In particular, `.config/gh/hosts.yml`, `.codex/auth.json`, `.claude.json`, and shell/editor histories must never be committed.
