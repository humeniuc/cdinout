# shellcheck shell=bash

__cdinout_prompt_command() {
    local CURDIR="$PWD"
    local CDINOUT_SCRIPTS_PATH="$HOME/.config/cdinout/paths"

    __cdinout_debug() {
        [ ! -z "$CDINOUT_DEBUG" ] && echo "CDINOUT: $1" >&2
    }

    __cdinout_debug "scanning"

    # Test if I am in a $CDINOUT_PATH subdirectory
    if [ -v "CDINOUT_PATH" ]; then
        until [ "$CURDIR" = "" ]; do
            __cdinout_debug "Testing $CURDIR"
            if [ "$CDINOUT_PATH" == "$CURDIR" ]; then
                __cdinout_debug "same dir. exit"
                return
            fi

            CURDIR="${CURDIR%/*}"
        done
    fi

    __cdinout_dir_path() {
        # Remove first slash
        DIR="${1/\//}"

        # Build path to the out script
        echo "$CDINOUT_SCRIPTS_PATH/$DIR"
    }

    # Out method
    __cdinout_out() {
        # Not in a special dir. Skip
        if [ ! -v "CDINOUT_PATH" ]; then
            return
        fi

        local CDINOUT_OUT_PATH
        CDINOUT_OUT_PATH="$(__cdinout_dir_path "$CDINOUT_PATH")/out.sh"
        # TODO: Check CDINOUT_OUT_PATH is a $HOME/.cdinout/scripts

        # Run the out script if exists
        if [ -f "$CDINOUT_OUT_PATH" ]; then
            __cdinout_debug "execute $CDINOUT_OUT_PATH"
            source "$CDINOUT_OUT_PATH"
        fi

        unset "CDINOUT_PATH"
    }

    # In method
    __cdinout_in() {
        # Allready in a special dir. Skip
        if [ -v "CDINOUT_PATH" ]; then
            return
        fi

        CURDIR="$PWD"
        until [ "$CURDIR" = "" ]; do
            local CDINOUT_IN_PATH
            CDINOUT_IN_PATH="$(__cdinout_dir_path "$CURDIR")/in.sh"

            # Run the in script, if exists.
            # Set the env var.
            if [ -f "$CDINOUT_IN_PATH" ]; then
                __cdinout_debug "execute $CDINOUT_IN_PATH"
                source "$CDINOUT_IN_PATH"
                export CDINOUT_PATH="$CURDIR"
                break;
            fi

            CURDIR="${CURDIR%/*}"
        done
    }

    __cdinout_out
    __cdinout_in

    unset -f __cdinout_dir_path
    unset -f __cdinout_out
    unset -f __cdinout_in
    unset -f __cdinout_debug
}

# Append command to PROMPT_COMMAND.
# Some projects tamper with the semicolon at the end, so I have to remove both version before add.
CDINOUT_CMD=$'\n''__cdinout_prompt_command'
PROMPT_COMMAND="${PROMPT_COMMAND/$CDINOUT_CMD;/}"
PROMPT_COMMAND="${PROMPT_COMMAND/$CDINOUT_CMD/}"
PROMPT_COMMAND="${PROMPT_COMMAND}$CDINOUT_CMD;"
unset "CDINOUT_CMD"

# Prevent allready defined env:
# Ex 1: From a special dir, start bash from bash
# Ex 2: From a special dir start tmux with working_dir a special dir
unset "CDINOUT_PATH"
