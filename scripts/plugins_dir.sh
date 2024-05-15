#!/usr/bin/env bash

default_plugins_path="$HOME/.tmux/plugins/"
xdg_plugins_path="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins"

if [ -d "$xdg_plugins_path" ]; then
    plugins_dir=$xdg_plugins_path
elif [ -d "$default_plugins_path" ]; then
    plugins_dir=$default_plugins_path
else
    echo "Can't find plugins path, make sure tpm is installed."
    exit 1
fi

echo $plugins_dir
