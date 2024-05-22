#!/usr/bin/env bash

plugins_dir=$1
new_plugin=${@:2}

if [ -f "$plugins_dir/../tmux.conf" ]; then
    conf="$plugins_dir/../tmux.conf"
elif [ -f "$plugins_dir/../.tmux.conf" ]; then
    conf="$plugins_dir/../.tmux.conf"
else
    conf=""
    new_plugin=""
fi

if [ -n "$conf" ] && [ -n "$new_plugin" ] && ! grep -qF "$new_plugin" "$conf"; then
    total_lines=$(wc -l < "$conf")
    last_two_lines=$(tail -n 2 "$conf")
    sed -i '' "$((total_lines - 1)) a\\
\\
$new_plugin

" "$conf"
    tmux source-file $conf
fi
