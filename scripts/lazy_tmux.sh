#!/usr/bin/env bash

if ! command -v gum &> /dev/null; then
    echo "Can't find gum, make sure it is installed first."
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGINS_DIR="$( sh $CURRENT_DIR/plugins_dir.sh )"

while true; do
    input="$( sh $CURRENT_DIR/select_action.sh $PLUGINS_DIR )"
    if [ -z "$input" ]; then
        exit 0
    elif [ "$input" == "Install" ]; then
        new_plugin="$( sh $CURRENT_DIR/select_plugin.sh )"
        if [ -z "$new_plugin" ]; then
           :
        else
            sh $CURRENT_DIR/add_plugin.sh $PLUGINS_DIR $new_plugin
            sh $PLUGINS_DIR/tpm/bin/install_plugins
        fi
    elif [ "$input" == "Update" ]; then
        sh $PLUGINS_DIR/tpm/bin/update_plugins all
    elif [ "$input" == "Clean" ]; then
        sh $PLUGINS_DIR/tpm/bin/clean_plugins
    elif [ "$input" == "Exit" ]; then
        exit 0
    else
        sh $PLUGINS_DIR/tpm/bin/update_plugins $input
    fi
done
