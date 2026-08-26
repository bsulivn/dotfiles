#!/bin/bash

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
SOURCE="$(pmset -g batt | head -1)"

if echo "$SOURCE" | grep -q "AC Power"; then
  ICON="⚡"
else
  ICON="BAT"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="$PERCENTAGE"
