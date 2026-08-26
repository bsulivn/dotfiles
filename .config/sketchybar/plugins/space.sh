#!/bin/bash

GREEN=0xff86efac
MUTED=0xff6b7280
ACTIVE_BG=0xff17211b

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    icon.color=$GREEN \
    background.drawing=on \
    background.color=$ACTIVE_BG \
    background.border_width=1 \
    background.border_color=$GREEN
else
  sketchybar --set "$NAME" \
    icon.color=$MUTED \
    background.drawing=off
fi
