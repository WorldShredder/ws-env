#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/utils.sh" --component depth2indent,+color

#
# Library
#

source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::report "$@"

if Plan::import --require 'format_index' -- 'ok'; then
    # Usage: report.ok TITLE [DEPTH]
    #
    # Prints the success status message to the event log.
    #
    # Positional Args:
    #   TITLE  The title of the success message, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.ok() {
        local title="$1"
        local -i depth="${2:-0}"
        local icon="${PLAN__STATLOG_OK_ICON::1}"

        tput cub "$(tput cols)"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf '%b%s' \
            "${PLAN__FG//@/$PLAN__STATLOG_OK_COLOR}" "$icon"
        if [ "$PLAN__STATLOG_SHOW_INDEX" = 'true' ]; then
            [ "$PLAN__STATLOG_STICKY_INDEX" = 'true' ] \
                && Plan::report.format_index
        fi
        printf ' %b%s\033[0m' \
            "${PLAN__FG//@/$PLAN__STATLOG_TITLE_COLOR}" "$title"
        [ "$PLAN__STATLOG_KEEP_TAIL" != 'true' ] \
            && tput el
        printf '\n'
    }
fi

if Plan::import --require 'format_index' -- 'fail'; then
    # Usage: report.fail TITLE [DEPTH]
    #
    # Prints the failure status message to the event log.
    #
    # Positional Args:
    #   TITLE  The title of the success message, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.fail() {
        local title="$1"
        local -i depth="${2:-0}"
        local icon="${PLAN__STATLOG_FAIL_ICON::1}"

        tput cub "$(tput cols)"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf '%b%s' \
            "${PLAN__FG//@/$PLAN__STATLOG_FAIL_COLOR}" "$icon"
        if [ "$PLAN__STATLOG_SHOW_INDEX" = 'true' ]; then
            [ "$PLAN__STATLOG_STICKY_INDEX" = 'true' ] \
                && Plan::report.format_index
        fi
        printf ' %b%s\033[0m' \
            "${PLAN__FG//@/$PLAN__STATLOG_TITLE_COLOR}" "$title"
        [ "$PLAN__STATLOG_KEEP_TAIL" != 'true' ] \
            && tput el
        printf '\n'
    }
fi

if Plan::import --require 'format_index' -- 'status'; then
    # Usage: report.status SPIN_CHAR TITLE [LAST] [DEPTH]
    #
    # Prints the given status line of a (presumably) running module.
    #
    # Positional Args:
    #   SPIN_CHAR  The current spinner character and spinner padding size in
    #              format 'CHAR:SIZE', e.g.: '⣴:3' => '⣴  '. This character is
    #              printed as the message prefix.
    #   TITLE      The title of the success message, e.g., module title.
    #   LAST       The last line of a module's log for realtime reporting or
    #              any message to print right of TITLE.
    #   DEPTH      The indentation multiplier for utils.depth2indent()
    #
    Plan::report.status() {
        local spin_char="${1%:*}"
        local -i spin_len="${1##*:}"
        local title="$2"
        local last="$3"
        local -i depth="${4:-0}"

        tput cub "$(tput cols)"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf "%b%-${spin_len}s" \
            "${PLAN__FG//@/$PLAN__STATLOG_SPINNER_COLOR}" "$spin_char"
        [ "$PLAN__STATLOG_SHOW_INDEX" = 'true' ] \
            && Plan::report.format_index
        printf ' %b%s' \
            "${PLAN__FG//@/$PLAN__STATLOG_TITLE_COLOR}" "$title"
        printf ' %b%s\033[0m' \
            "${PLAN__FG//@/$PLAN__STATLOG_TAIL_COLOR}" "$last"
        tput el
        printf '\r'
    }
fi

if Plan::import 'dir'; then
    # Usage: report.dir TITLE [DEPTH]
    #
    # Prints a given title with directory styling.
    #
    # Positional Args:
    #   TITLE  The name of the directory/sub-module, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.dir() {
        local title="$1"
        local -i depth="${2:-0}"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        local icon=''
        [ -n "$PLAN__STATLOG_DIR_ICON" ] \
            && local icon="${PLAN__STATLOG_DIR_ICON::1} "
        printf '%b%s%b%s\033[0m\n' \
            "${PLAN__FG//@/$PLAN__STATLOG_DIR_COLOR}" "$icon" \
            "${PLAN__FG//@/$PLAN__STATLOG_DIR_TITLE_COLOR}" "$title"
    }
fi

if Plan::import 'format_index'; then
    # Usage: report.format_index
    #
    # Formats and prints the current index without a newline.
    #
    Plan::report.format_index() {
        printf " %b%s%b%+${#PLAN__NUM_MODULES}s%b%s%b%s%b%s" \
            "${PLAN__FG//@/$PLAN__STATLOG_INDEX_BRACKET_COLOR}" \
            "$PLAN__STATLOG_INDEX_BRACKET_L" \
            "${PLAN__FG//@/$PLAN__STATLOG_INDEX_L_COLOR}" \
            "$PLAN__MODULE_INDEX" \
            "${PLAN__FG//@/$PLAN__STATLOG_INDEX_DIVIDER_COLOR}" \
            "$PLAN__STATLOG_INDEX_DIVIDER" \
            "${PLAN__FG//@/$PLAN__STATLOG_INDEX_R_COLOR}" \
            "$PLAN__NUM_MODULES" \
            "${PLAN__FG//@/$PLAN__STATLOG_INDEX_BRACKET_COLOR}" \
            "$PLAN__STATLOG_INDEX_BRACKET_R"
    }
fi

Plan::import.clean
