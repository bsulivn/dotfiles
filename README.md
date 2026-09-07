# macOS development environment

My personal macOS development environment: yabai, SketchyBar, Karabiner-Elements, Neovim/LazyVim, Ghostty, terminal tooling, and AI coding-agent configuration.

> **Screenshot TODO:** Add one safe screenshot of the desktop, terminal, or editor setup here if it communicates the workflow better than text. Do not include notifications, private paths, tokens, client data, or other personal information.

## Overview

This repository stores configuration using paths relative to `$HOME`. It is designed to make a working environment inspectable and recoverable while leaving machine-specific credentials, histories, caches, and runtime state outside version control.

## Key tools

- **Window management:** yabai, `skhd`, JankyBorders, SketchyBar
- **Keyboard and input:** Karabiner-Elements with a Caps Lock hyper key
- **Terminal:** Ghostty, zsh, shell helpers, tmux-compatible workflows
- **Editors:** Neovim/LazyVim, Zed, and VS Code
- **AI tooling:** selected Codex, Claude, and OpenCode configuration that contains no credentials or conversation history
- **Package management:** Homebrew via `Brewfile`

## Window management

The window-management layer combines a modal keyboard workflow with predictable spaces, focus, movement, resizing, fullscreen, floating, and layout controls. See `.skhdrc`, `.yabairc`, `.config/borders/`, and `.config/sketchybar/` for the implementation.

## Keyboard and navigation philosophy

Caps Lock acts as Escape when tapped and as a Command-Control-Option-Shift hyper key when held. The intent is to keep common window, workspace, terminal, and editor actions close to the home row and discoverable through the configured help bindings.

## Terminal, editor, and agent setup

The repository includes shell startup files, Git and GitHub CLI preferences, Ghostty, Zed, VS Code, Neovim/LazyVim configuration, plugin lockfiles, and selected agent definitions. The configuration is personal and opinionated; review each file before copying it to another machine.

## Installation

Clone the repository, install Homebrew dependencies, review the diff against the destination machine, and then copy or symlink only the files you want:

```sh
git clone https://github.com/bsulivn/dotfiles.git
cd dotfiles
brew bundle install
```

Grant the required macOS Accessibility permissions before starting yabai, `skhd`, and SketchyBar. The display-padding script contains a machine-specific display UUID; update it when restoring to different hardware.

## Collie

The repository includes a tracked `.config/collie/.env.example` for the local Collie setup. The live environment file remains outside version control. Install Collie separately, copy the example to `~/.config/collie/.env`, set the local trusted-user value, generate fresh keys with `collie push-keys`, and review the template comments before enabling its launchd and Tailscale integration.

## Repository structure

- `.config/`: application and tool configuration
- `.claude/`, `.codex/`, `.config/opencode/`: selected agent and research tooling configuration
- `Library/Application Support/`: files mirrored to their native macOS locations
- shell dotfiles: zsh, bash, tcsh, Git, and yabai/skhd settings
- `Brewfile`: Homebrew taps, formulae, casks, extensions, and selected CLI tools

## Notes and caveats

Authentication files, API credentials, shell/editor histories, databases, logs, caches, backups, and generated runtime state must remain untracked. In particular, never commit `.config/gh/hosts.yml`, `.codex/auth.json`, `.claude.json`, or local histories.

`Brewfile` contains two deliberate corrections to the output of `brew bundle dump --force`: explicit `yabai`/`skhd` entries and a fully qualified tap reference. Re-check those corrections after regenerating the file.
