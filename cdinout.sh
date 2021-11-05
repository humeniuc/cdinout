cdinout_prompt_command() {
    local CURDIR="$PWD"
    until [ "$CURDIR" = "" ]; do
        if [ "$CDINOUT_PATH" == "$CURDIR" ]; then
            return
        fi

        CURDIR="${CURDIR%/*}"
    done

    _cdinout_dir_path() {
        # Remove first slash
        DIR="${1/\//}"

        # Build path to the out script
        echo "$HOME/.cdinout/scripts/$DIR"
    }

    # Out method
    _cdinout_out() {
        if [ -v "CDINOUT_PATH" ]; then
            local CDINOUT_OUT_PATH="$(_cdinout_dir_path "$CDINOUT_PATH")/out.sh"
            # TODO: Check CDINOUT_OUT_PATH is a $HOME/.cdinout/scripts

            # Run the out script if exists
            if [ -f "$CDINOUT_OUT_PATH" ]; then
                source "$CDINOUT_OUT_PATH"
            fi

            unset "CDINOUT_PATH"
        fi   

        return
    }

    # In method
    _cdinout_in() {
        CURDIR="$PWD"
        until [ "$CURDIR" = "" ]; do
            local CDINOUT_IN_PATH="$(_cdinout_dir_path "$CURDIR")/in.sh"

            # Run the in script, if exists.
            # Set the env var.
            if [ -f "$CDINOUT_IN_PATH" ]; then
                source $CDINOUT_IN_PATH
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

cdinout_prompt_command_cmd=$'\n''cdinout_prompt_command'$'\n'
PROMPT_COMMAND="${PROMPT_COMMAND/$cdinout_prompt_command_cmd/}$cdinout_prompt_command_cmd"
