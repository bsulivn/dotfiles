#!/bin/sh
# Install the checked-in themed icons into the local macOS application bundles.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

copy_icon() {
  app=$1
  resource=$2
  source=$3

  if [ ! -d "$app" ]; then
    printf 'Skipping missing app: %s\n' "$app"
    return
  fi

  target="$app/Contents/Resources/$resource"
  if cp "$root/$source" "$target" 2>/dev/null; then
    touch "$app"
  else
    # Some downloaded app bundles carry a macOS protection xattr that rejects
    # writes even as root. Copy without extended attributes, replace the
    # bundle, and re-sign it ad hoc after changing the sealed resource.
    staging=$(mktemp -d "${TMPDIR:-/tmp}/everforest-app.XXXXXX")
    replacement="$staging/$(basename "$app")"
    cp -RX "$app" "$replacement"
    cp "$root/$source" "$replacement/Contents/Resources/$resource"
    sudo sh -c '\n      set -eu\n      backup=$(mktemp -d "${TMPDIR:-/tmp}/everforest-original.XXXXXX")\n      mv "$1" "$backup/app"\n      if ! mv "$2" "$1"; then\n        mv "$backup/app" "$1"\n        exit 1\n      fi\n      codesign --deep --force --sign - "$1"\n      rm -rf "$backup"\n    ' install "$app" "$replacement"
    rm -rf "$staging"
  fi
  # Replacing a sealed .icns resource invalidates the vendor signature.
  codesign --deep --force --sign - "$app" >/dev/null 2>&1 || true
  printf 'Installed %s → %s\n' "$source" "$target"
}

copy_icon "/Applications/Ghostty.app" Ghostty.icns Ghostty-Everforest.icns
copy_icon "/Applications/Visual Studio Code.app" Code.icns Visual-Studio-Code-Everforest.icns
# Some VS Code builds retain a lowercase alias; keep both names themed.
if [ -f "/Applications/Visual Studio Code.app/Contents/Resources/code.icns" ]; then
  copy_icon "/Applications/Visual Studio Code.app" code.icns Visual-Studio-Code-Everforest.icns
fi

# Refresh the Finder/Dock icon cache after replacing bundle resources.
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
