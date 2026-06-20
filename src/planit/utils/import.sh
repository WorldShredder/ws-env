#!/usr/bin/env bash

# Usage: source path/to/library [OPTION ...]
#
# Bootstraps new libraries with on-demand import functionality. Provides
# two functions -- Plan::import() and Plan::import.clean() -- to manage your
# import environment.
#
# Positional Args:
#   NAMESPACE  The namespace assigned to the library and used in the name of
#              each library component, e.g., 'Plan::utils' in 'Plan::utils.md5'.
#
# Options
#   -c, --component  Specify one or more components to source; comma-separated.
#                    If no components are specified, all are imported.
#   -o, --overwrite  Overwrite existing components; disabled by default.
#
# Library Initialization
#   source path/to/import.sh NAMESPACE
#
# Library Components
#   if Plan::import 'MyFunction'; then
#       NameSpace.MyFunction() { echo 123; }
#   fi
#
# Importing Components
#   source my/my_lib.sh --component MyFunction
#

__NAMESPACE__="$1"
__OVERWRITE__='false'
shift

declare -a __C__

while :; do
    case "$1" in
        -c | --component)
            IFS=, read -ra __C__ <<< "$2"
            shift
            ;;
        -o | --overwrite)
            __OVERWRITE__='true'
            ;;
        --)
            shift
            break
            ;;
        *) break ;;
    esac
    shift
done

if ! declare -F 'Plan::import' &> /dev/null; then
    # Usage: import [-o|--overwrite] [-n|--namespace NAME] [COMPONENT]
    #
    # Checks the current environment for a given function under __NAMESPACE__
    # and returns non-zero exit code if function exists, unless -o|--overwrite
    # is set or __OVERWRITE__ is 'true'.
    #
    # If an array __C__ exists and is non-empty, import() will return '0' if
    # COMPONENT can be found in the array, otherwise return '1'.
    #
    # Positional Args:
    #   COMPONENT  The component to check for under __NAMESPACE__. If COMPONENT
    #              starts with an '+', the component is considered a component
    #              group, where everything after the '+' is the group identifier.
    #              In this mode import() will declare a function with an fname of
    #              identifier under __NAMESPACE__ if it does not already exist.
    #
    # Args:
    #   -o, --overwrite
    #              Return 0 even if COMPONENT exists in environment. If not
    #              set, value of __OVERWRITE__ is used.
    #   -n, --namespace NAME
    #              The namespace to check under, otherwise namespace is value
    #              of __NAMESPACE__.
    #   -r, --require REQUIRED
    #              Comma-separated string of required library components. This
    #              Is necessary for component functions that all rely on the same
    #              independent function within the component. Required components
    #              extend the __C__ array and must be defined after the component
    #              requiring them.
    #
    Plan::import() {
        local namespace="$__NAMESPACE__"
        local overwrite="$__OVERWRITE__"

        while :; do
            case "$1" in
                -n | --namespace)
                    namespace="$2"
                    shift
                    ;;
                -o | --overwrite)
                    overwrite='true'
                    ;;
                -r | --require)
                    # only extend components array when not importing all
                    if [ "${#__C__[@]}" -gt 0 ]; then
                        local required req
                        IFS=, read -ra required <<< "$2"
                        for req in "${required[@]}"; do
                            __C__+=("$req")
                        done
                    fi
                    shift
                    ;;
                --)
                    shift
                    break
                    ;;
                *) break ;;
            esac
            shift
        done

        local component="$1"
        local call_path="$namespace"
        if [ "${component::1}" = '+' ]; then
            ! [[ "${component:1}" =~ ^[a-zA-Z0-9\._]+$ ]] \
                && return 1
            call_path+=".${component:1}"
        elif [ -n "$component" ]; then
            call_path+=".${component}"
        fi

        if declare -F "$call_path" &> /dev/null; then
            if [ "$overwrite" != 'true' ]; then
                [ "$__DEBUG_IMPORT__" = 'true' ] \
                    && Plan::import._debug 'Skipping'
                return 1
            fi
        fi

        # array expansion is safe here since IFS should never be in component name
        if [ -z "${__C__[*]}" ] || [[ " ${__C__[*]} " == *" $component "* ]]; then
            [ "${component::1}" = '+' ] \
                && eval "function $call_path { :; }"
            [ "$__DEBUG_IMPORT__" = 'true' ] \
                && Plan::import._debug 'Importing'
            return 0
        fi

        [ "$__DEBUG_IMPORT__" = 'true' ] \
            && Plan::import._debug 'Ignoring'

        return 1
    }

    Plan::import.clean() {
        # Usage: import.clean
        #
        # Cleanup environment variables defined by import.sh
        #
        unset __C__ __NAMESPACE__ __OVERWRITE__
        unset -f Plan::import._debug Plan::import.clean Plan::import
    }

    Plan::import._debug() {
        local prefix="$1"
        printf '\033[32m[DEBUG] import: %-10s %-15s %-25s\033[0m\n' \
            "$prefix" "$component" "$call_path"
        ## Debug w/callstack (only shows source depth)
        # local -i i
        # local call_stack="${FUNCNAME[1]}"
        # for ((i = 2; i < "${#FUNCNAME[@]}"; i++)); do
        #     call_stack+=" <- ${FUNCNAME[$i]}"
        # done
        # printf '\033[32m[DEBUG] import: %-10s %-15s %-25s <= %s\033[0m\n' \
        #     "$prefix" "$component" "$call_path" "$call_stack"
    }
fi
