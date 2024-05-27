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

if [ -n "$conf" ] && [ -n "$old_width" ] && [ -n "$new_width" ]; then
    if grep -qF "$old_width" "$conf"; then
        sed -i '' "/^$old_line/d" "$conf"
    fi
    total_lines=$(wc -l < "$conf")
    last_two_lines=$(tail -n 2 "$conf")
    sed -i '' "$((total_lines - 1)) a\\
\\
$new_line

" "$conf"
    tmux source-file $conf
fi
