#!/bin/sh
# Recolor the stock app artwork and package all macOS icon sizes.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/everforest-icons.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

package_png() {
  source=$1
  iconset=$2
  rm -rf "$root/$iconset"
  mkdir -p "$root/$iconset"

  resize() {
    size=$1
    filename=$2
    sips -z "$size" "$size" "$source" --out "$root/$iconset/$filename" >/dev/null
  }

  resize 16 icon_16x16.png
  resize 32 icon_16x16@2x.png
  resize 32 icon_32x32.png
  resize 64 icon_32x32@2x.png
  resize 128 icon_128x128.png
  resize 256 icon_128x128@2x.png
  resize 256 icon_256x256.png
  resize 512 icon_256x256@2x.png
  resize 512 icon_512x512.png
  resize 1024 icon_512x512@2x.png

  iconutil -c icns "$root/$iconset" -o "$root/${iconset%.iconset}.icns"
  rm -rf "$root/$iconset"
}

sips -s format png "$root/ghostty-original.icns" --out "$tmp/ghostty-original.png" >/dev/null
swift "$root/recolor-ghostty.swift" "$tmp/ghostty-original.png" "$tmp/ghostty-everforest.png"
package_png "$tmp/ghostty-everforest.png" Ghostty-Everforest.iconset

sips -s format png "$root/vscode-original.icns" --out "$tmp/vscode-original.png" >/dev/null
swift "$root/recolor-vscode.swift" "$tmp/vscode-original.png" "$tmp/vscode-everforest.png"
package_png "$tmp/vscode-everforest.png" Visual-Studio-Code-Everforest.iconset

printf 'Built Ghostty-Everforest.icns and Visual-Studio-Code-Everforest.icns\n'
