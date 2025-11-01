# shellcheck shell=bash

# adaug la path CDINOUT
export PATH="$(dirname "$( readlink -f "${BASH_SOURCE[0]}" )")/bin:$PATH"

__cdinout_prompt_command() {
    source "$(dirname "$( readlink -f "${BASH_SOURCE[0]}" )")/lib.sh"

    if ! __cdinout_check_same_dir; then
        __cdinout_out
        __cdinout_in
    fi

    __cdinout_unset_functions
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
