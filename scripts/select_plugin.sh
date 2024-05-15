#!/usr/bin/env bash

plugin=$(gum input --placeholder "IdoKendo/lazy.tmux")
line_to_add="set -g @plugin '$plugin'"
if [ -z "$plugin" ]; then
   echo ""
else
    echo $line_to_add
fi
