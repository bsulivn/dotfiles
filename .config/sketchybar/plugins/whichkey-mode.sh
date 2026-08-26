#!/bin/bash

# Reuse the popup's fixed rows and show the requested command layer.
requested_mode="${1:-default}"

case "$requested_mode" in
  default)
    heading="CAPS / SUPER"
    secondary_heading="Command Layer"
    popup_state="off"
    keys=("h j k l" "1–5" "m" "r" "f" "t" "b" "↵" "space" "'")
    descriptions=(
      "Focus Left / Down / Up / Right"
      "Switch Workspace"
      "Move Mode"
      "Resize Mode"
      "Toggle Fullscreen"
      "Toggle Float"
      "Balance Layout"
      "Ghostty"
      "Raycast"
      "Toggle Help"
    )
    ;;
  move)
    heading="MOVE MODE"
    secondary_heading="Esc to exit"
    popup_state="on"
    keys=("h j k l" "1–5")
    descriptions=(
      "Swap Left / Down / Up / Right"
      "Move Window to Workspace"
    )
    ;;
  resize)
    heading="RESIZE MODE"
    secondary_heading="Esc to exit"
    popup_state="on"
    keys=("h j k l")
    descriptions=("Resize Left / Down / Up / Right")
    ;;
  *)
    printf 'Usage: %s [default|move|resize]\n' "${0##*/}" >&2
    exit 2
    ;;
esac

# Failing quietly keeps skhd usable while SketchyBar is restarting.
if ! command -v sketchybar >/dev/null 2>&1; then
  exit 0
fi

sketchybar_arguments=(
  --set whichkey popup.drawing=off
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

sketchybar_arguments+=(--set whichkey "popup.drawing=$popup_state")

sketchybar "${sketchybar_arguments[@]}" >/dev/null 2>&1 || exit 0
