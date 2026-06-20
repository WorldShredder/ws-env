#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/report.sh" --component status

#
# Library
#

# Usage: monitor.start PID [ARGS ...]
#
# Run a process monitor for a given process ID.
#
# Positional Args:
#   PID   The ID of the process to monitor.
#   ARGS  Additional args passed to monitor.loop().
#
# Return:
#   Exit code of given process.
#
Plan::monitor.run() {
    local proc_pid="$1"
    Plan::monitor.loop "$@" &
    local loop_pid="$!"

    wait "$proc_pid"
    local proc_code="$?"
    wait "$loop_pid"

    return "$proc_code"
}

# Usage: monitor.loop PID LOG_PATH [OPTIONS ...]
#
# Monitor a given PID and loop over process log entries from LOG_PATH.
# This function consumes a single terminal line to print the latest log entry
# and truncates the entry if it exceeds `tput cols`.
#
# Positional Args:
#   PID       The process ID to monitor.
#   LOG_PATH  Log file path to retrieve process logs from.
#
# Options:
#   -t, --title TITLE
#             Module title to display after spinner.
#   -d, --depth DEPTH
#             Depth of current module. This is a multiplier for
#             PLAN__STATLOG_TAB_LEN.
#   -s, --spinner SPINNER
#             Space-separated string of spinner segments to iterate over while
#             the loop is active. Displayed in front of -t|--title.
#
# Return:
#   Exit code (1) on error.
#
Plan::monitor.loop() {
    local proc_pid="$1"
    local log_path="$2"
    shift 2

    [ -z "$proc_pid" ] &&
        return 1

    local title="${PLAN__MODULE_TITLE:-Running Process}"
    local -i depth=0
    local spinner_str="${PLAN__STATLOG_SPINNER:-'\ \ | | / / - -'}"

    while :; do
        case "$1" in
            -t|--title) title="$2"; shift;;
            -d|--depth) depth="$2"; shift;;
            -s|--spinner) spinner_str="$2"; shift;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    local -a spinner
    IFS=' ' read -ra spinner <<< "$spinner_str"

    # Num spaces between elements
    local -i spacing=2

    # Max spinner length
    local c
    local -i spin_len=0
    for c in "${spinner[@]}"; do
        (( ${#c} > spin_len )) && spin_len="${#c}"
    done

    # Module index length
    local -i index_len=0
    if [ "$PLAN__STATLOG_SHOW_INDEX" = 'true' ]; then
        index_len+="${#PLAN__NUM_MODULES} * 2"
        index_len+="${#PLAN__STATLOG_INDEX_BRACKET_L}"
        index_len+="${#PLAN__STATLOG_INDEX_DIVIDER}"
        index_len+="${#PLAN__STATLOG_INDEX_BRACKET_R}"
        spacing+=1
    fi

    # Total prefix length
    local -i pre_len
    local -i indent="$depth * $PLAN__STATLOG_TAB_LEN"
    pre_len="$indent + $spin_len + $index_len + ${#title} + $spacing"

    # Main report loop
    local last _last
    while kill -0 "$proc_pid" 2>/dev/null; do
        if [ "$PLAN__STATLOG_GET_TAIL" != 'false' ]; then
            _last="$(tail -n1 "$log_path" 2>/dev/null || :)"
            [ -n "$_last" ] &&
                last="$_last"
            # absolute get rid of these
            last="${last//$'\r'/}"
            last="${last//$'\n'/}"
        fi

        # TODO: move truncate to report.status() on whole message
        local -i delta
        delta="$(tput cols)"-"$pre_len"-"${#last}"
        (( delta < 0 )) &&
            last="${last::delta-3}..."

        local -i spin_idx="${spin_idx:-0}"
        local spin_char="${spinner[$spin_idx]}"

        Plan::report.status \
            "${spin_char}:${spin_len}" \
            "$title" \
            "$last" \
            "$depth"

        spin_idx=(spin_idx+1)%"${#spinner[@]}"
        sleep 0.05
    done
}

