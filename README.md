# dotfiles

My current macOS development environment, stored using paths relative to `$HOME`.

## Included

- Hyper key and app shortcuts: Karabiner-Elements and `skhd`
- Window appearance and command hints: JankyBorders and SketchyBar
- Neovim/LazyVim configuration, plugins, keymaps, and lockfile
- Shell startup files for zsh, bash, and tcsh
- Git and GitHub CLI preferences
- Ghostty, Zed, VS Code, and OpenCode settings
- bb (agent orchestration) Everforest theme: app palette plus matching dark/light syntax highlighting, IBM Plex Mono throughout
- Selected Codex and Claude agent configuration that contains no credentials or history

The Hyper layer maps Caps Lock to Command-Control-Option-Shift when held and Escape when tapped. See `.skhdrc` for app launchers and help bindings.

## Installation

Run from a normal macOS Terminal (sandboxed agents may be unable to build Homebrew
formulae or mount app disk images). Install Homebrew first from https://brew.sh.

```sh
cd ~/Developer/dotfiles
./install.sh
```

The installer sets up Rust when missing, installs the Brewfile (including the Spaceship prompt),
and checks dependencies, required desktop configs, and running services. It can
partially install packages and still exit nonzero: fix the reported errors and
rerun it. It does not overwrite existing configuration files. Restore the configs
as described below before starting the desktop services.

```sh
# After restoring configs and granting skhd Accessibility permission:
./install.sh --start-services
# Verify without installing or restarting anything:
./install.sh --check
```

A successful package installation does not prove a service is running. The installer
checks launchd state for skhd and SketchyBar and exits nonzero if any is stopped.
Complete Karabiner-Elements permission prompts in its app. Herdr is installed
but its server is optional: `brew services start herdr`.

## Homebrew dependencies

`brew bundle install` remains available for package-only installation.

`Brewfile` is generated with `brew bundle dump --force` and covers taps, formulae, casks, VS Code extensions, and the cargo/npm-installed CLI tools. Two things `brew bundle dump` gets wrong on its own, already fixed in the checked-in `Brewfile` (see the comments there):

- `skhd` may be omitted by a plain re-dump, so it is pinned explicitly.
- The `koekeishiya/formulae` tap resolves to the `asmvik/homebrew-formulae` fork. The fully qualified `skhd` formula avoids ambiguity with the separately tapped `asmvik/formulae`.

Review `brew bundle dump --force` changes before committing: keep the explicit skhd
entry and the fonts, Raycast, and Zed required by the configs. Keep InterSystems
packages excluded. `agent-mem` and `agent-memory` are unavailable on crates.io and are
excluded from automatic installation until their original sources are known.

After granting the required macOS Accessibility permissions, run `./install.sh --start-services` to start `skhd` and SketchyBar.

## Restoring

Clone the repository, run `./install.sh`, review the diff against the destination machine, then copy or symlink the desired files to the matching paths under `$HOME`. Files under `Library/Application Support` intentionally mirror their native macOS locations.

## Safety

Authentication files, API credentials, histories, databases, logs, caches, backups, generated runtime state, and local-only settings are excluded. In particular, `.config/gh/hosts.yml`, `.codex/auth.json`, `.claude.json`, and shell/editor histories must never be committed.
