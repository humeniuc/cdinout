# shellcheck shell=bash

__cdinout_prompt_command() {
    local CDINOUT_SCRIPTS_PATH="$HOME/.config/cdinout/paths"

    __cdinout_check_same_dir()
    {
        __cdinout_debug "scanning"
        local CURDIR="$PWD"

        # Test if I am in a $CDINOUT_PATH subdirectory
        if [ -v "CDINOUT_PATH" ]; then
            until [ "$CURDIR" = "" ]; do
                __cdinout_debug "Testing $CURDIR"
                if [ "$CDINOUT_PATH" == "$CURDIR" ]; then
                    __cdinout_debug "same dir. exit"
                    return 0
                fi

                CURDIR="${CURDIR%/*}"
            done
        fi

        return 1
    }


    # Out method
    __cdinout_out()
    {
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
    __cdinout_in()
    {
        # Allready in a special dir. Skip
        if [ -v "CDINOUT_PATH" ]; then
            return
        fi

        local CURDIR="$PWD"

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


    __cdinout_dir_path()
    {
        # Remove first slash
        DIR="${1/\//}"

        # Build path to the out script
        echo "$CDINOUT_SCRIPTS_PATH/$DIR"
    }


    # Prepend PATH with a path
    __cdinout_path_prepend()
    {
        __cdinout_debug "prepend $1"

        __cdinout_path_remove "$1"
        export PATH="$1:$PATH"
        unset LOCAL_PATH
    }


    # Remove a path from PATH
    __cdinout_path_remove()
    {
        __cdinout_debug "remove $1"

        PATH=":$PATH:"
        PATH="${PATH/:$1:/:}"
        PATH="${PATH#:}"
        PATH="${PATH%:}"
        export PATH="$PATH"
    }


    __cdinout_debug() {
        [ ! -z "$CDINOUT_DEBUG" ] && echo "CDINOUT: $1" >&2
    }


    if ! __cdinout_check_same_dir; then
        __cdinout_out
        __cdinout_in
    fi

    unset -f __cdinout_path_prepend
    unset -f __cdinout_path_remove
    unset -f __cdinout_dir_path
    unset -f __cdinout_debug
    unset -f __cdinout_out
    unset -f __cdinout_in
    unset -f __cdinout_check_same_dir
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
