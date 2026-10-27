#!/usr/bin/env sh

# `space --balance` operates on the focused space only. Iterate BSP spaces so
# the shortcut still works when focus is on an unmanaged fullscreen space.
yabai_bin=/opt/homebrew/bin/yabai
spaces=$(/usr/bin/jq -r '.[] | select(.type == "bsp") | .index' <<EOF
$($yabai_bin -m query --spaces)
EOF
) || exit 1
current=$(/usr/bin/jq -r '.[] | select(."has-focus") | .index' <<EOF
$($yabai_bin -m query --spaces)
EOF
)

for space in $spaces; do
  if [ "$space" != "$current" ]; then
    "$yabai_bin" -m space --focus "$space" || continue
  fi
  "$yabai_bin" -m space --balance
 done

if [ -n "$current" ] && [ "$current" != "$space" ]; then
  "$yabai_bin" -m space --focus "$current"
fi
