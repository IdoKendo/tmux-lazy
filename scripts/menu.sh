#!/usr/bin/env bash

WIDTH=$1

if ! command -v gum &> /dev/null; then
    echo "Can't find gum, make sure it is installed first."
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGINS_DIR="$( sh "$CURRENT_DIR/plugins_dir.sh" )"
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

    find "$PLUGINS_DIR" -type d -name .git -print0 | xargs -0 -I {} -P 0 sh -c 'cd "$(dirname "{}")" && git fetch --quiet' 2> /dev/null

    for item in "$PLUGINS_DIR"/*; do
      if [ -d "$item" ]; then
        if [ -d "$item/.git" ]; then
          (
          cd "$item" || return

          LOCAL=$(git rev-parse @)
          REMOTE=$(git rev-parse '@{u}')
          NAME="$(basename "$item")"

          if [ "$LOCAL" != "$REMOTE" ]; then
              echo "- $NAME (new commits)" | gum format
          else
              echo "- $NAME" | gum format
          fi

          if [ "$FIRST_RUN" = 1 ]; then
              echo "$NAME" "$LOCAL" >> "$LOCKFILE"
          fi
          )
        else
          echo "- $(basename "$item") (not a git repo)" | gum format
        fi
      fi
    done
    FIRST_RUN=0
    echo ""

    SELECTION=$(bash -c 'read -n1 -s key; echo "$key"')

    case "$SELECTION" in
        i|I)
            PLUGIN_NAME=$(gum input --placeholder "IdoKendo/tmux-lazy")
            if [ -n "$PLUGIN_NAME" ]; then
                sh "$CURRENT_DIR/add_plugin.sh" "$PLUGINS_DIR" "set -g @plugin '$PLUGIN_NAME'"
                sh "$PLUGINS_DIR/tpm/bin/install_plugins"
            fi
            ;;
        r|R)
            INSTALLED_PLUGINS=""
            for item in "$PLUGINS_DIR"/*; do
              if [ -d "$item" ]; then
                NAME="$(basename "$item")"
                INSTALLED_PLUGINS="$INSTALLED_PLUGINS$NAME"$'\n'
              fi
            done
            
            if command -v fzf &> /dev/null; then
                PLUGIN_NAME=$(echo "$INSTALLED_PLUGINS" | fzf --prompt "Select plugin to remove: " --height 40%)
            else
                PLUGIN_NAME=$(echo "$INSTALLED_PLUGINS" | gum filter --placeholder "Select plugin to remove...")
            fi
            
            if [ -n "$PLUGIN_NAME" ]; then
                sh "$CURRENT_DIR/remove_plugin.sh" "$PLUGINS_DIR" "$PLUGIN_NAME"
            fi
            ;;
        u|U)
            sh "$PLUGINS_DIR/tpm/bin/update_plugins" all
            FIRST_RUN=1
            echo "" > "$LOCKFILE"
            ;;
        s|S)
            sh "$CURRENT_DIR/sync_plugins.sh" "$PLUGINS_DIR" "$LOCKFILE"
            ;;
        c|C)
            sh "$PLUGINS_DIR/tpm/bin/clean_plugins"
            ;;
        x|X|$'\e')
            exit 0
            ;;
        +)
            sh "$CURRENT_DIR/adjust_width.sh" "$PLUGINS_DIR" "$WIDTH" "$((WIDTH + 5))"
            echo "Increased width, please restart Lazy.tmux"
            sleep 2
            ;;
        -)
            sh "$CURRENT_DIR/adjust_width.sh" "$PLUGINS_DIR" "$WIDTH" "$((WIDTH - 5))"
            echo "Decreased width, please restart Lazy.tmux"
            sleep 2
            ;;
    esac
done
