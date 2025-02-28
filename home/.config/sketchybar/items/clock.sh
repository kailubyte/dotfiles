#!/bin/bash

source "$CONFIG_DIR/icons.sh"

clock=(
  padding_right=10
  padding_left=-10
  script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
           --set clock "${clock[@]}" \
           --set clock update_freq=10 icon=  script="$PLUGIN_DIR/clock.sh" \
