#!/usr/bin/env sh

# Keep the existing MacBook padding, but reserve SketchyBar's full footprint on
# this external monitor: 38px height + 4px y-offset + the existing 18px gap.
external_display_uuid="59693652-732B-42D2-BED3-EEBAAA3E693D"
default_top_padding=18
external_top_padding=60

yabai_bin="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
jq_bin="${JQ_BIN:-/usr/bin/jq}"

displays=$("$yabai_bin" -m query --displays) || exit 1

printf '%s\n' "$displays" |
  "$jq_bin" -r \
    --arg external_uuid "$external_display_uuid" \
    --argjson default_padding "$default_top_padding" \
    --argjson external_padding "$external_top_padding" \
    '.[]
     | .uuid as $display_uuid
     | .spaces[]
     | "\(.) \(if $display_uuid == $external_uuid then $external_padding else $default_padding end)"' |
  while read -r space_index top_padding; do
    "$yabai_bin" -m config --space "$space_index" top_padding "$top_padding"
  done
