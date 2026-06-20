#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/logging.sh" --component logger
source "${PLAN__PATH_ROOT}/lib/utils.sh" --component hr,+color

#
# Library
#

source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::proc "$@"

if Plan::import 'cleanup'; then
    # Usage: proc.cleanup [-p|--pids ARRAY_REF] [-f|--files ARRAY_REF]
    #
    # Cleanup filesystem after Planit has completed or failed.
    #
    # Options:
    #   -p, --pids   A name reference pointing to the array holding process
    #                IDs to terminate.
    #   -f, --files  A name reference pointing to the array holding files
    #                to cleanup from system.
    #
    Plan::proc.cleanup() {
        local pids files
        while :; do
            case "$1" in
                -p | --pids)
                    local -n pids="$2"
                    shift
                    ;;
                -f | --files)
                    local -n files="$2"
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
        local target
        for target in "${pids[@]}"; do
            Plan::proc.terminate "$target"
        done
        for target in "${files[@]}"; do
            Plan::log.debug "Removing file '$target'"
            rm -rf "$target"
        done
    }

    # Usage: proc.terminate PID
    #
    # Gracefully terminates a process.
    #
    Plan::proc.terminate() {
        local pid="$1"
        if [ -z "$pid" ] || ! kill -0 "$pid" 2> /dev/null; then
            return 0
        fi

        Plan::log.debug "Terminating process '$pid'"
        kill -TERM "$pid" 2> /dev/null

        local -i count=0
        local -i timeout="${PLAN__TERM_TIMEOUT:-10}"

        while kill -0 "$pid" 2> /dev/null && ((count < timeout)); do
            count+=1
            sleep 1
        done

        if kill -0 "$pid" 2> /dev/null; then
            Plan::log.debug "Killing stalled process '$pid'"
            kill -KILL "$pid" 2> /dev/null
            wait "$pid" 2> /dev/null
        fi

        return 0
    }
fi

if Plan::import --require 'print_errlog' -- 'exit'; then
    # Usage: proc.exit [OPTIONS ...] [CLEANUP_OPTS ...]
    #
    # Handle INT, TERM, HUP, QUIT and EXIT signals with cleanup step.
    #
    # Positional Args:
    #   CLEANUP_OPTS  Options to pass to a cleanup function defined by -C.
    #
    # Options:
    #   -c, --code     Exit code to pass to exit.
    #   -g, --group    Process group to forcefully terminate as a final step.
    #                  Group termination is ignored if no group is given.
    #   -C, --cleanup  Name of a cleanup function that takes two optional
    #                  arrays as name references via -p|--pids and -f|--files.
    #                  If not given, Plan::proc.cleanup() is used.
    #
    Plan::proc.exit() {
        trap - INT TERM HUP QUIT EXIT
        tput cnorm

        local code=0
        local group=''
        local cleanup='Plan::proc.cleanup'
        while :; do
            case "$1" in
                -c | --code)
                    [[ "${2// /}" =~ ^[0-9]+$ ]] \
                        && code="$2"
                    shift
                    ;;
                -g | --group)
                    [[ "${2// /}" =~ ^[0-9]+$ ]] \
                        && group="$2"
                    shift
                    ;;
                -C | --cleanup)
                    cleanup="$2"
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

        if [ "$code" != '0' ]; then
            Plan::proc.print_errlog
            local show_log_dir_path
            [ -d "$PLAN__PATH_LOG" ] && [ "$PLAN__MODULES_LOG_KEEP" == 'true' ] \
                && show_log_dir_path=" (see: '$PLAN__PATH_LOG')"
            local message="Planit failed with exit code '$code'"
            Plan::log.error "${message}${show_log_dir_path}"
        fi

        if declare -F "$cleanup" &> /dev/null; then
            "$cleanup" "$@" || true
        else
            Plan::log.warn "Undefined cleanup method '$cleanup'"
        fi

        [ -n "$group" ] \
            && kill -- -"${group}" &> /dev/null

        exit "$code"
    }
fi

if Plan::import 'print_errlog'; then
    # Usage: proc.print_errlog [MESSAGER]
    #
    # Prints the last process error log or given MESSAGE as a formatted string.
    #
    # Positional Args:
    #   MESSAGE  A message to print in-place of the process error log.
    #
    Plan::proc.print_errlog() {
        local message="${1:-$(cat "$PLAN__PATH_LOG_ERR" 2> /dev/null)}"
        if [ -n "$message" ]; then
            Plan::utils.hr '1:52' " $PLAN__PATH_LOG_ERR " >&2
            printf '%b%s\033[0m\n' "${PLAN__FG//@/$PLAN__STATLOG_FAIL_COLOR}" "$message" >&2
            Plan::utils.hr '1:52' >&2
        fi
    }
fi

Plan::import.clean
