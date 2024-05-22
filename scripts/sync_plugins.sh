#!/usr/bin/env bash

plugins_dir=$1
lockfile=$2

while IFS=' ' read -r plugin commit_hash; do
    if [ -z "$plugin" ] || [ -z "$commit_hash" ]; then
        continue
    fi

    if [ -d "$plugins_dir/$plugin" ]; then
        cd "$plugins_dir/$plugin"
        git reset --hard "$commit_hash" > /dev/null
        cd - > /dev/null
    else
        echo "$plugin does not exist"
    fi
done < "$lockfile"

sleep 5
