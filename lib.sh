__cdinout_scripts_path()
{
    echo "${HOME}/.config/cdinout/paths"
}


__cdinout_in_path()
{
    if [ -v "CDINOUT_PATH" -a "${CDINOUT_PATH}" != "" ]; then
        echo "$(__cdinout_dir_path "${CDINOUT_PATH}")/in.sh"
    fi
}

__cdinout_out_path()
{
    if [ -v "CDINOUT_PATH" -a "${CDINOUT_PATH}" != "" ]; then
        echo "$(__cdinout_dir_path "${CDINOUT_PATH}")/out.sh"
    fi
}


# find the closest upwards dir with in/out scripts
__cdinout_closest_dir()
{
    local CURDIR="$PWD"
    local CDINOUT_IN_PATH

    until [ "$CURDIR" = "" ]; do
        # __cdinout_debug "analizing ${CURDIR}"
        CDINOUT_IN_PATH="$(__cdinout_dir_path "${CURDIR}")/in.sh"

        if [ -f "${CDINOUT_IN_PATH}" ]; then
            # __cdinout_debug "match ${CURDIR}"
            echo "${CURDIR}";
            break;
        fi

        CURDIR="${CURDIR%/*}"
    done
}


# check if inside the same in/out dir
__cdinout_check_same_dir()
{
    __cdinout_debug "scanning"
    local CLOSEST_DIR="$(__cdinout_closest_dir)"

    # Test if I am in a $CDINOUT_PATH subdirectory
    if [ -v "CDINOUT_PATH" -a "${CDINOUT_PATH}" != "" -a "${CDINOUT_PATH}" = "${CLOSEST_DIR}" ]; then
        __cdinout_debug "same dir. exit"
        return 0
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

    local CDINOUT_OUT_PATH="$( __cdinout_out_path )"
    # TODO: Check CDINOUT_OUT_PATH is a $HOME/.cdinout/scripts

    # Run the out script if exists
    if [ -f "${CDINOUT_OUT_PATH}" ]; then
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
    local CLOSEST_DIR="$(__cdinout_closest_dir)"

    if [ "${CLOSEST_DIR}" = "" ]; then
        __cdinout_debug "no closest dir"
    else
        CDINOUT_IN_PATH="$(__cdinout_dir_path "${CLOSEST_DIR}")/in.sh"
        __cdinout_debug "execute ${CDINOUT_IN_PATH}"
        source "${CDINOUT_IN_PATH}"
        export CDINOUT_PATH="${CLOSEST_DIR}"
    fi
}


__cdinout_dir_path()
{
    # Remove first slash
    DIR="${1/\//}"

    # Build path to the out script
    echo "$( __cdinout_scripts_path )/${DIR}"
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


__cdinout_unset_functions()
{
    unset -f __cdinout_scripts_path
    unset -f __cdinout_path_prepend
    unset -f __cdinout_path_remove
    unset -f __cdinout_dir_path
    unset -f __cdinout_debug
    unset -f __cdinout_out
    unset -f __cdinout_in
    unset -f __cdinout_check_same_dir
    unset -f __cdinout_closest_dir
    unset -f __cdinout_unset_functions
}
