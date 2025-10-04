#!/usr/bin/env bash

plugins_dir=$1
old_width=$2
new_width=$3

if [ -f "$plugins_dir/../tmux.conf" ]; then
    conf="$plugins_dir/../tmux.conf"
elif [ -f "$plugins_dir/../.tmux.conf" ]; then
    conf="$plugins_dir/../.tmux.conf"
else
    conf=""
    old_width=""
    new_width=""
fi

old_line="set -g @lazy-tmux-width '$old_width'"
new_line="set -g @lazy-tmux-width '$new_width'"

if [ -n "$conf" ] && [ -n "$new_width" ]; then
	if grep -qF "$old_line" "$conf"; then
		grep -vxF "$old_line" "$conf" > "$conf.tmp" && mv "$conf.tmp" "$conf"
	fi
	
	total_lines=$(wc -l < "$conf")
	insert_line=$((total_lines - 1))
	
	head -n "$insert_line" "$conf" > "$conf.tmp"
	echo "" >> "$conf.tmp"
	echo "$new_line" >> "$conf.tmp"
	tail -n +$((insert_line + 1)) "$conf" >> "$conf.tmp"
	mv "$conf.tmp" "$conf"
	
	tmux source-file "$conf" 2>/dev/null || true
fi
