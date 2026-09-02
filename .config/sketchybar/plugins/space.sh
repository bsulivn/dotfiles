#!/bin/bash

# Everforest Dark — medium contrast palette
GREEN=0xffa7c080
MUTED=0xff859289
ACTIVE_BG=0xff3d484d

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
