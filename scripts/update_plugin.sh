#!/usr/bin/env bash

plugins_dir=$1
lockfile=$2
plugin=$3

sh $plugins_dir/tpm/bin/update_plugins $plugin
cd "$plugins_dir/$plugin"
new_commit_hash=$(git rev-parse @)
sed -i '' -e "s|^$plugin .*|$plugin $new_commit_hash|" "$lockfile"
cd - > /dev/null
