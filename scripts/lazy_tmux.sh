#!/usr/bin/env bash

if ! command -v gum &> /dev/null; then
    echo "Can't find gum, make sure it is installed first."
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGINS_DIR="$( sh $CURRENT_DIR/plugins_dir.sh )"

INSTALL=$(gum style --padding "0 1" --border double "[I] Install")
REMOVE=$(gum style --padding "0 1" --border double "[R] Remove")
UPDATE=$(gum style --padding "0 1" --border double "[U] Update")
SYNC=$(gum style --padding "0 1" --border double "[S] Sync")
CLEAN=$(gum style --padding "0 1" --border double "[C] Clean")
EXIT=$(gum style --padding "0 1" --border double "[X] Exit")

while true; do
    clear
    gum join --align center "$INSTALL" "$REMOVE" "$UPDATE" "$SYNC" "$CLEAN" "$EXIT"

    find "$PLUGINS_DIR" -type d -name .git | xargs -I {} -P 10 sh -c 'cd "$(dirname "{}")"; git fetch --quiet'
    declare -a OPTIONS=("Install" "Remove" "Update" "Sync" "Clean")

    for item in "$PLUGINS_DIR"/*; do
      if [ -d "$item" ]; then
        if [ -d "$item/.git" ]; then
          cd "$item"

          LOCAL=$(git rev-parse @)
          REMOTE=$(git rev-parse @{u})

          if [ "$LOCAL" != "$REMOTE" ]; then
              echo "- $(basename "$item") (new commits)" | gum format
          else
              echo "- $(basename "$item")" | gum format
          fi
          options+=("$(basename "$item")")

          cd - > /dev/null
        else
          echo "- $(basename "$item") (not a git repo)" | gum format
        fi
      fi
    done
    echo ""

    options+=("Exit")

    SELECTION=$(gum input)

    if [ -z "$SELECTION" ]; then
        exit 0
    elif [ "$SELECTION" == "I" ] || [ "$SELECTION" == "Install" ]; then
        NEW_PLUGIN="$( sh $CURRENT_DIR/select_plugin.sh )"
        if [ -z "$NEW_PLUGIN" ]; then
           :
        else
            sh $CURRENT_DIR/add_plugin.sh $PLUGINS_DIR $NEW_PLUGIN
            sh $PLUGINS_DIR/tpm/bin/install_plugins
        fi
    elif [ "$SELECTION" == "R" ] || [ "$SELECTION" == "Remove" ]; then
        :
    elif [ "$SELECTION" == "U" ] || [ "$SELECTION" == "Update" ]; then
        :
    elif [ "$SELECTION" == "S" ] || [ "$SELECTION" == "Sync" ]; then
        sh $PLUGINS_DIR/tpm/bin/update_plugins all
    elif [ "$SELECTION" == "C" ] || [ "$SELECTION" == "Clean" ]; then
        sh $PLUGINS_DIR/tpm/bin/clean_plugins
    elif [ "$SELECTION" == "X" ] || [ "$SELECTION" == "Exit" ]; then
        exit 0
    else
        sh $PLUGINS_DIR/tpm/bin/update_plugins $SELECTION
    fi
done
