#!/usr/bin/env bash

WIDTH=$1

if ! command -v gum &> /dev/null; then
    echo "Can't find gum, make sure it is installed first."
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGINS_DIR="$( sh $CURRENT_DIR/plugins_dir.sh )"
LOCKFILE="$PLUGINS_DIR/../lazy.tmux.lock"
FIRST_RUN=0
if [ ! -f "$LOCKFILE" ]; then
    FIRST_RUN=1
fi

INSTALL=$(gum style --padding "0 1" --border double "[I] Install")
REMOVE=$(gum style --padding "0 1" --border double "[R] Remove")
UPDATE=$(gum style --padding "0 1" --border double "[U] Update")
SYNC=$(gum style --padding "0 1" --border double "[S] Sync")
CLEAN=$(gum style --padding "0 1" --border double "[C] Clean")
EXIT=$(gum style --padding "0 1" --border double "[X] Exit")

while true; do
    clear
    gum join --align center "$INSTALL" "$REMOVE" "$UPDATE" "$SYNC" "$CLEAN" "$EXIT"
    echo "To change width use (+/-)"

    find "$PLUGINS_DIR" -type d -name .git | xargs -I {} -P 0 sh -c 'cd "$(dirname "{}")" && git fetch --quiet' 2> /dev/null

    for item in "$PLUGINS_DIR"/*; do
      if [ -d "$item" ]; then
        if [ -d "$item/.git" ]; then
          cd "$item"

          LOCAL=$(git rev-parse @)
          REMOTE=$(git rev-parse @{u})
          NAME="$(basename "$item")"

          if [ "$LOCAL" != "$REMOTE" ]; then
              echo "- $NAME (new commits)" | gum format
          else
              echo "- $NAME" | gum format
          fi

          if [ "$FIRST_RUN" = 1 ]; then
              echo $NAME $LOCAL >> $LOCKFILE
          fi

          cd - > /dev/null
        else
          echo "- $(basename "$item") (not a git repo)" | gum format
        fi
      fi
    done
    FIRST_RUN=0
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
        FIRST_RUN=1
        echo "" > $LOCKFILE
    elif [ "$SELECTION" == "S" ] || [ "$SELECTION" == "Sync" ]; then
        sh $CURRENT_DIR/sync_plugins.sh $PLUGINS_DIR $LOCKFILE
    elif [ "$SELECTION" == "C" ] || [ "$SELECTION" == "Clean" ]; then
        sh $PLUGINS_DIR/tpm/bin/clean_plugins
    elif [ "$SELECTION" == "X" ] || [ "$SELECTION" == "Exit" ]; then
        exit 0
    elif [ "$SELECTION" == "+" ]; then
        sh $CURRENT_DIR/adjust_width.sh $PLUGINS_DIR $WIDTH "$((WIDTH + 5))"
        echo "Increased width, please restart Lazy.tmux"
        sleep 2
    elif [ "$SELECTION" == "-" ]; then
        sh $CURRENT_DIR/adjust_width.sh $PLUGINS_DIR $WIDTH "$((WIDTH - 5))"
        echo "Decreased width, please restart Lazy.tmux"
        sleep 2
    else
        sh $CURRENT_DIR/update_plugin.sh $PLUGINS_DIR $LOCKFILE $SELECTION
    fi
done
