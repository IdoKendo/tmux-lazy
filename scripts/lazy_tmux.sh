#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux_option_or_fallback() {
	local option_value
	option_value="$(tmux show-option -gqv "$1")"
	if [ -z "$option_value" ]; then
		option_value="$2"
	fi
	echo "$option_value"
}

TERMINAL_WIDTH=$(tmux display-message -p '#{window_width}')
TERMINAL_HEIGHT=$(tmux display-message -p '#{window_height}')

WIDTH_PERCENT="$(tmux_option_or_fallback "@lazy-tmux-width" "65")"

WIDTH=$(( TERMINAL_WIDTH * WIDTH_PERCENT / 100 ))
HEIGHT=$(( TERMINAL_HEIGHT * 70 / 100 ))

# Cap maximum sizes for better usability
if [ $WIDTH -gt 120 ]; then WIDTH=120; fi
if [ $HEIGHT -gt 40 ]; then HEIGHT=40; fi

# Ensure minimum sizes
if [ $WIDTH -lt 50 ]; then WIDTH=50; fi
if [ $HEIGHT -lt 20 ]; then HEIGHT=20; fi

tmux popup -b rounded -h $HEIGHT -w $WIDTH -T "Lazy.tmux" -E "cd $CURRENT_DIR && $CURRENT_DIR/menu.sh $WIDTH_PERCENT"
