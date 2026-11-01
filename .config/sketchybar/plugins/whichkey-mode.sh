#!/bin/bash

# Reuse the popup's fixed rows and show the requested command layer.
requested_mode="${1:-default}"

case "$requested_mode" in
  default)
    heading="CAPS / SUPER"
    secondary_heading="Command Layer"
    popup_state="off"
    keys=("↵" "space" "c" "s" "'")
    descriptions=(
      "Ghostty"
      "Raycast"
      "Visual Studio Code"
      "Safari"
      "Toggle Help"
    )
    ;;
  *)
    printf 'Usage: %s [default]\n' "${0##*/}" >&2
    exit 2
    ;;
esac

# Refresh labels without changing visibility when the toggle invokes this script.
if [ "${2:-}" = "keep-popup" ]; then
  popup_state="keep"
fi

# Failing quietly keeps skhd usable while SketchyBar is restarting.
if ! command -v sketchybar >/dev/null 2>&1; then
  exit 0
fi

sketchybar_arguments=()
if [ "$popup_state" != "keep" ]; then
  sketchybar_arguments+=(--set whichkey popup.drawing=off)
fi
sketchybar_arguments+=(
  --set whichkey.header
  "drawing=on"
  "icon=$heading"
  "label=$secondary_heading"
)

for row_number in {1..10}; do
  array_index=$((row_number - 1))
  row_name="whichkey.row${row_number}"

  if [ "$array_index" -lt "${#keys[@]}" ]; then
    sketchybar_arguments+=(
      --set "$row_name"
      "drawing=on"
      "icon=${keys[$array_index]}"
      "label=${descriptions[$array_index]}"
    )
  else
    sketchybar_arguments+=(
      --set "$row_name"
      "drawing=off"
      "icon="
      "label="
    )
  fi
done

if [ "$popup_state" != "keep" ]; then
  sketchybar_arguments+=(--set whichkey "popup.drawing=$popup_state")
fi

sketchybar "${sketchybar_arguments[@]}" >/dev/null 2>&1 || exit 0
