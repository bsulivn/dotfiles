#!/usr/bin/env bash
# Install dependencies; configuration files are restored separately (see README).
set -euo pipefail
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
check_only=0
start_services=0
with_collie=0
for arg in "$@"; do
  case "$arg" in
    --check) check_only=1 ;;
    --start-services) start_services=1 ;;
    --with-collie) with_collie=1 ;;
    -h|--help)
      echo 'Usage: ./install.sh [--check] [--start-services] [--with-collie]'
      echo 'Run in macOS Terminal. Existing configuration files are not overwritten.'
      echo '--check verifies dependencies, configs, and desktop services without installing.'
      echo '--start-services starts/restarts yabai, skhd, and SketchyBar after config restore.'
      echo '--with-collie also installs the optional Collie binary (no remote service is started).'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
if [[ "$check_only" == 1 && "$start_services" == 1 ]]; then
  echo '--check cannot be combined with --start-services.' >&2
  exit 2
fi
[[ $(uname -s) == Darwin ]] || { echo 'This installer requires macOS.' >&2; exit 1; }
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v brew >/dev/null || { echo 'Install Homebrew from https://brew.sh, then rerun this script.' >&2; exit 1; }
# Keep TLS verification enabled and include the macOS certificate bundle for npm.
export NODE_EXTRA_CA_CERTS="${NODE_EXTRA_CA_CERTS:-/etc/ssl/cert.pem}"
status=0
failed() { echo "ATTENTION: $*" >&2; status=1; }

if [[ "$check_only" == 0 ]]; then
  if [[ ! -f "$HOME/.cargo/env" ]]; then
    installer=$(mktemp)
    if curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o "$installer"; then
      sh "$installer" -y --no-modify-path || failed 'Rust installation failed.'
    else
      failed 'Could not download the Rust installer.'
    fi
    rm -f "$installer"
  fi
  if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || failed 'Oh My Zsh installation failed.'
  fi
  # Bundle may partially succeed. Always verify and preserve its failure status.
  brew bundle install --file="$repo_dir/Brewfile" || failed 'Some Brewfile dependencies failed to install. Review the errors above.'
  if [[ "$with_collie" == 1 ]] && ! command -v collie >/dev/null; then
    installer=$(mktemp)
    if curl --proto '=https' --tlsv1.2 -fsSL https://colliepwa.dev/install.sh -o "$installer"; then
      sh "$installer" || failed 'Collie installation failed.'
    else
      failed 'Could not download the Collie installer.'
    fi
    rm -f "$installer"
  fi
fi

brew bundle check --verbose --file="$repo_dir/Brewfile" || failed 'Brewfile dependencies are missing or need updating.'
[[ -f "$HOME/.cargo/env" ]] || failed 'Missing ~/.cargo/env required by the shell dotfiles.'
[[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] || failed 'Oh My Zsh is missing.'
if [[ "$with_collie" == 1 ]]; then
  command -v collie >/dev/null || failed 'Collie is missing.'
fi
configs_ready=1
for config in .yabairc .skhdrc .config/sketchybar/sketchybarrc .config/yabai/update-display-padding.sh .config/sketchybar/plugins/whichkey-mode.sh .config/karabiner/karabiner.json; do
  if [[ ! -f "$HOME/$config" ]]; then
    failed "Missing ~/$config; restore the repo configs first (see README)."
    configs_ready=0
  fi
done
if [[ "$start_services" == 1 && "$configs_ready" == 1 ]]; then
  for daemon in yabai skhd; do
    if command -v "$daemon" >/dev/null; then
      # The restart command requires an existing launch agent.
      if [[ "$daemon" == yabai ]]; then label=com.asmvik.yabai; else label=com.koekeishiya.skhd; fi
      if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then
        "$daemon" --restart-service || failed "Could not restart $daemon."
      else
        "$daemon" --start-service || failed "Could not start $daemon."
      fi
    else
      failed "$daemon is not installed."
    fi
  done
  brew services restart sketchybar || failed 'Could not start SketchyBar.'
  sleep 2
fi
for label in com.asmvik.yabai com.koekeishiya.skhd sh.brew.sketchybar; do
  if launchctl print "gui/$(id -u)/$label" 2>/dev/null | grep -q 'state = running'; then
    echo "RUNNING: $label"
  else
    failed "$label is not running."
  fi
done
cat <<'NOTES'

Manual setup:
- Enable yabai and skhd in System Settings > Privacy & Security > Accessibility.
  Then run ./install.sh --start-services from Terminal. Inspect /tmp/yabai_$USER.err.log
  and /tmp/skhd_$USER.err.log if either service exits immediately.
- Open Karabiner-Elements and complete its permission prompts for Caps Lock shortcuts.
- Borders is launched by ~/.yabairc; a separate Homebrew Borders service is unnecessary.
- Update the external monitor UUID in ~/.config/yabai/update-display-padding.sh.
- Herdr is installed; optionally start its server with: brew services start herdr
- Collie requires a trusted Tailscale identity, fresh push keys, and pairing; see README.
- OpenCode's local model server at 127.0.0.1:8888 must be set up separately.
- agent-mem and agent-memory are unavailable on crates.io; their original sources are needed.
NOTES
if [[ "$status" == 0 ]]; then
  echo 'Dependency and desktop-service checks passed. Review the manual setup notes above.'
else
  echo 'Setup is incomplete. Resolve the items above, then rerun ./install.sh --check.' >&2
fi
exit "$status"
