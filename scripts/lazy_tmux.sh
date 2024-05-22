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

HEIGHT=60
WIDTH="$(tmux_option_or_fallback "@lazy-tmux-width" "55")"

tmux popup -b rounded -h ${HEIGHT}% -w ${WIDTH}% -T "Lazy.tmux" -E "cd $CURRENT_DIR && $CURRENT_DIR/menu.sh $WIDTH"
