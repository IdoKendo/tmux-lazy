#!/usr/bin/env bash

plugins_dir=$1
find "$plugins_dir" -type d -name .git | xargs -I {} -P 10 sh -c 'cd "$(dirname "{}")"; git fetch --quiet'
declare -a dir_list=("Install New Plugin" "Update All Plugins" "Clean Stale Plugins")

for item in "$plugins_dir"/*; do
  if [ -d "$item" ]; then
    if [ -d "$item/.git" ]; then
      cd "$item"

      LOCAL=$(git rev-parse @)
      REMOTE=$(git rev-parse @{u})

      if [ "$LOCAL" != "$REMOTE" ]; then
        dir_list+=("$(basename "$item") (new commits)")
      else
        dir_list+=("$(basename "$item")")
      fi

      cd - > /dev/null
    else
      dir_list+=("$(basename "$item") (not a git repo)")
    fi
  fi
done

dir_list+=("Exit")

selected=$(gum filter --no-limit --header "Select action or plugin to update" "${dir_list[@]}")
read -ra words <<< "$selected"
echo "${words}"
