# dotfiles

My current macOS development environment, stored using paths relative to `$HOME`.

## Included

- Hyper key and modal window controls: Karabiner-Elements, `skhd`, and `yabai`
- Window appearance and command hints: JankyBorders and SketchyBar
- Neovim/LazyVim configuration, plugins, keymaps, and lockfile
- Shell startup files for zsh, bash, and tcsh
- Git and GitHub CLI preferences
- Ghostty, Zed, VS Code, and OpenCode settings
- bb (agent orchestration) Everforest theme: app palette plus matching dark/light syntax highlighting, IBM Plex Mono throughout
- Selected Codex and Claude agent configuration that contains no credentials or history
- Collie config template (`.config/collie/.env.example`) — the live `.env` holds the Web Push private key and stays untracked

The Hyper layer maps Caps Lock to Command-Control-Option-Shift when held and Escape when tapped. See `.skhdrc` for focus, workspace, move, resize, fullscreen, float, balance, Ghostty, Raycast, and help bindings.

## Installation

Run from a normal macOS Terminal (sandboxed agents may be unable to build Homebrew
formulae or mount app disk images). Install Homebrew first from https://brew.sh.

```sh
cd ~/Developer/dotfiles
./install.sh
```

The installer sets up Rust and Oh My Zsh when missing, installs the Brewfile,
and checks dependencies, required desktop configs, and running services. It can
partially install packages and still exit nonzero: fix the reported errors and
rerun it. It does not overwrite existing configuration files. Restore the configs
as described below before starting the desktop services.

```sh
# After restoring configs and granting yabai/skhd Accessibility permission:
./install.sh --start-services
# Verify without installing or restarting anything:
./install.sh --check
# Optionally install Collie, without enabling remote access:
./install.sh --with-collie
```

A successful package installation does not prove a service is running. The installer
checks launchd state for yabai, skhd, and SketchyBar and exits nonzero if any is stopped.
Complete Karabiner-Elements permission prompts in its app. Borders is started by
`.yabairc`; do not start a second Borders instance with Homebrew. Herdr is installed
but its server is optional: `brew services start herdr`.

## Homebrew dependencies

`brew bundle install` remains available for package-only installation.

`Brewfile` is generated with `brew bundle dump --force` and covers taps, formulae, casks, VS Code extensions, and the cargo/npm-installed CLI tools. Two things `brew bundle dump` gets wrong on its own, already fixed in the checked-in `Brewfile` (see the comments there):

- `yabai` and `skhd` don't reinstall from a plain re-dump — Homebrew doesn't mark them "installed on request" on this machine, so `brew bundle dump` silently drops them. They're pinned in explicitly.
- The `koekeishiya/formulae` tap actually resolves to `asmvik/homebrew-formulae.git`, a fork, not the upstream koekeishiya repo — and `asmvik/formulae` is tapped separately too, with its own conflicting `yabai`/`skhd`. The Brewfile uses the fully-qualified `koekeishiya/formulae/yabai` name to avoid the ambiguity. If you ever re-tap from scratch, tapping the plain name will *not* reproduce this setup — use the URL on the `tap` line.

Review `brew bundle dump --force` changes before committing: keep the explicit window
manager entries and the fonts, Raycast, and Zed required by the configs. Keep InterSystems
packages excluded. `agent-mem` and `agent-memory` are unavailable on crates.io and are
excluded from automatic installation until their original sources are known.

After granting the required macOS Accessibility permissions, run `./install.sh --start-services` to start `yabai`, `skhd`, and SketchyBar. The external-display padding script contains this machine's display UUID; update `.config/yabai/update-display-padding.sh` when restoring to different hardware.

## Collie

[Collie](https://colliepwa.dev) is installed by its own script, not Homebrew: `curl -fsSL https://colliepwa.dev/install.sh | sh` puts the binary under `~/.local/share/collie` and links `collie` into `~/.local/bin`. Copy the tracked `.config/collie/.env.example` to `~/.config/collie/.env`, set `COLLIE_TRUSTED_USER`, and run `collie push-keys` to generate fresh VAPID keys. `collie start` creates the launchd agent and the `tailscale serve` mapping, but enabling Serve on the tailnet is a one-time browser step as tailnet admin — the full checklist is in the comments at the top of the template. Pair phones with `collie pair`.

## Restoring

Clone the repository, run `./install.sh`, review the diff against the destination machine, then copy or symlink the desired files to the matching paths under `$HOME`. Files under `Library/Application Support` intentionally mirror their native macOS locations.

## Safety

Authentication files, API credentials, histories, databases, logs, caches, backups, generated runtime state, and local-only settings are excluded. In particular, `.config/gh/hosts.yml`, `.codex/auth.json`, `.claude.json`, and shell/editor histories must never be committed.
