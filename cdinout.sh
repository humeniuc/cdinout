# shellcheck shell=bash

cdinout_prompt_command() {
    local CURDIR="$PWD"

    [ ! -z "$CDINOUT_DEBUG" ] && echo ".cdinout: scanning"

    # Test if I am in a $CDINOUT_PATH subdirectory
    if [ -v "CDINOUT_PATH" ]; then
        until [ "$CURDIR" = "" ]; do
            if [ "$CDINOUT_PATH" == "$CURDIR" ]; then
                [ ! -z "$CDINOUT_DEBUG" ] && echo ".cdinout: same dir"
                return
            fi

            CURDIR="${CURDIR%/*}"
        done
    fi

    _cdinout_dir_path() {
        # Remove first slash
        DIR="${1/\//}"

        # Build path to the out script
        echo "$HOME/.cdinout/scripts/$DIR"
    }

    # Out method
    _cdinout_out() {
        # Not in a special dir. Skip
        if [ ! -v "CDINOUT_PATH" ]; then
            return
        fi

        local CDINOUT_OUT_PATH
        CDINOUT_OUT_PATH="$(_cdinout_dir_path "$CDINOUT_PATH")/out.sh"
        # TODO: Check CDINOUT_OUT_PATH is a $HOME/.cdinout/scripts

        # Run the out script if exists
        if [ -f "$CDINOUT_OUT_PATH" ]; then
            [ ! -z "$CDINOUT_DEBUG" ] && echo ".cdinout: execute $CDINOUT_OUT_PATH"
            source "$CDINOUT_OUT_PATH"
        fi

        unset "CDINOUT_PATH"
    }

    # In method
    _cdinout_in() {
        # Allready in a special dir. Skip
        if [ -v "CDINOUT_PATH" ]; then
            return
        fi

        CURDIR="$PWD"
        until [ "$CURDIR" = "" ]; do
            local CDINOUT_IN_PATH
            CDINOUT_IN_PATH="$(_cdinout_dir_path "$CURDIR")/in.sh"

            # Run the in script, if exists.
            # Set the env var.
            if [ -f "$CDINOUT_IN_PATH" ]; then
                [ ! -z "$CDINOUT_DEBUG" ] && echo ".cdinout: execute $CDINOUT_IN_PATH"
                source "$CDINOUT_IN_PATH"
                export CDINOUT_PATH="$CURDIR"
                break;
            fi

            CURDIR="${CURDIR%/*}"
        done
    }

    _cdinout_out
    _cdinout_in

    unset -f _cdinout_dir_path
    unset -f _cdinout_out
    unset -f _cdinout_in
}

cdinout_prompt_command_cmd=$'\n''cdinout_prompt_command;'
PROMPT_COMMAND="${PROMPT_COMMAND/$cdinout_prompt_command_cmd/}$cdinout_prompt_command_cmd"

# Prevent allready defined env:
# Ex 1: From a special dir, start bash from bash
# Ex 2: From a special dir start tmux with working_dir a special dir
unset "CDINOUT_PATH"
