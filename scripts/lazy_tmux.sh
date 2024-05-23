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

    find "$PLUGINS_DIR" -type d -name .git | xargs -I {} -P 0 sh -c 'cd "$(dirname "{}")" && git fetch --quiet' 2> /dev/null

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

          cd - > /dev/null
        else
          echo "- $(basename "$item") (not a git repo)" | gum format
        fi
      fi
    done
    echo ""

    SELECTION=$(gum input)

    if [ -z "$SELECTION" ]; then
        exit 0
    elif [ "$SELECTION" == "I" ] || [ "$SELECTION" == "Install" ]; then
        PLUGIN_NAME=$(gum input --placeholder "IdoKendo/tmux-lazy")
        if [ -z "$PLUGIN_NAME" ]; then
           :
        else
            NEW_PLUGIN="set -g @plugin '$PLUGIN_NAME'"
            sh $CURRENT_DIR/add_plugin.sh $PLUGINS_DIR $NEW_PLUGIN
            sh $PLUGINS_DIR/tpm/bin/install_plugins
        fi
    elif [ "$SELECTION" == "R" ] || [ "$SELECTION" == "Remove" ]; then
        PLUGIN_NAME=$(gum input --placeholder "tmux-lazy")
        if [ -z "$PLUGIN_NAME" ]; then
           :
        else
            sh $CURRENT_DIR/remove_plugin.sh $PLUGINS_DIR $PLUGIN_NAME
        fi
    elif [ "$SELECTION" == "U" ] || [ "$SELECTION" == "Update" ]; then
        sh $PLUGINS_DIR/tpm/bin/update_plugins all
    elif [ "$SELECTION" == "S" ] || [ "$SELECTION" == "Sync" ]; then
        echo "Not implemented yet..."
        sleep 1
    elif [ "$SELECTION" == "C" ] || [ "$SELECTION" == "Clean" ]; then
        sh $PLUGINS_DIR/tpm/bin/clean_plugins
    elif [ "$SELECTION" == "X" ] || [ "$SELECTION" == "Exit" ]; then
        exit 0
    else
        sh $PLUGINS_DIR/tpm/bin/update_plugins $SELECTION
    fi
done
