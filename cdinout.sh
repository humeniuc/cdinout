cdinout_prompt_command() {
    CURDIR="$PWD"
    until [ "$CURDIR" = "" ]; do
        if [ "$CDINOUT_PATH" == "$CURDIR" ]; then
            echo "same dir $CURDIR"
            return
        fi

        CURDIR="${CURDIR%/*}"
    done

    cmdinout_execute_out
    cmdinout_execute_in 
}

cmdinout_execute_out() {
    if [ -v "CDINOUT_PATH" ]; then
        # Remove first slash
        DIR="${CDINOUT_PATH/\//}"

        # Build path to the out script
        CDINOUT_OUT_PATH="$HOME/.cdinout/scripts/$DIR/out.sh"
        echo "CDINOUT_OUT_PATH=$CDINOUT_OUT_PATH"

        # Run the out script if exists
        if [ -f "$CDINOUT_OUT_PATH" ]; then
            source "$CDINOUT_OUT_PATH"
        fi

        unset "CDINOUT_PATH"
    fi   

    return
}

cmdinout_execute_in() {
    CURDIR="$PWD"
    until [ "$CURDIR" = "" ]; do
        # Remove first slash
        DIR="${CURDIR/\//}"

        # Build path to the in script
        CDINOUT_IN_PATH="$HOME/.cdinout/scripts/$DIR/in.sh"

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

cdinout_prompt_command_cmd=$'\n''cdinout_prompt_command'$'\n'
PROMPT_COMMAND="${PROMPT_COMMAND/$cdinout_prompt_command_cmd/}$cdinout_prompt_command_cmd"
