#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux_option_or_fallback() {
	local option_value
	option_value="$(tmux show-option -gqv "$1")"
	if [ -z "$option_value" ]; then
		option_value="$2"
	fi
	echo "$option_value"
}

tmux bind-key "$(tmux_option_or_fallback "@lazy-tmux-binding" "Z")" display-popup -h 60% -w 30% -T "Lazy.tmux" -E "cd $CURRENT_DIR && $CURRENT_DIR/scripts/lazy_tmux.sh"
