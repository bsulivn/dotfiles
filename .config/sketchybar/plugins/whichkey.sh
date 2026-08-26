#!/bin/bash

# Toggle the native SketchyBar popup without depending on its current state.
requested_action="${1:-toggle}"

case "$requested_action" in
  show)
    popup_state="on"
    ;;
  hide)
    popup_state="off"
    ;;
  toggle)
    popup_state="toggle"
    ;;
  *)
    printf 'Usage: %s [show|hide|toggle]\n' "${0##*/}" >&2
    exit 2
    ;;
esac

# SketchyBar may be unavailable during login, restart, or package updates.
if ! command -v sketchybar >/dev/null 2>&1; then
  exit 0
fi

sketchybar --set whichkey popup.drawing="$popup_state" >/dev/null 2>&1 || exit 0
