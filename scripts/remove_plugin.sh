#!/usr/bin/env bash

plugins_dir=$1
plugin_name=$2

if [ -f "$plugins_dir/../tmux.conf" ]; then
    conf="$plugins_dir/../tmux.conf"
elif [ -f "$plugins_dir/../.tmux.conf" ]; then
    conf="$plugins_dir/../.tmux.conf"
else
    conf=""
    plugin_name=""
fi

delete_plugin() {
    sed -i '' "/^set -g @plugin.*$plugin_name/d" "$conf"
    rm -rf "$plugins_dir/$plugin_name"
    tmux source-file $conf
}

if [ -n "$conf" ] && [ -n "$plugin_name" ]; then
    gum confirm "About to delete $plugin_name, are you sure?" && delete_plugin
fi
