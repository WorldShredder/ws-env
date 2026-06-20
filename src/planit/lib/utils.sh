#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Library
#

source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::utils "$@"

if Plan::import 'parse_cmd'; then
    # Usage: utils.parse_cmd ARRAY_REF [COMMAND ...]
    #
    # Parses input strings as a shell command and feeds it into an array given
    # by nameref. Command parsing is handled by Bash with noglob set.
    #
    # Positional Args:
    #   ARRAY_REF  Nameref of an array to feed parsed commands into.
    #   COMMAND    Space separated list of command strings to parse.
    #
    # Example:
    #   utils.parse_cmd arr 'bash'
    #   utils.parse_cmd arr 'source'
    #   utils.parse_cmd arr 'python3'
    #   utils.parse_cmd arr 'env foo="$foo" bar=true bash'
    #
    Plan::utils.parse_cmd() {
        local -n nameref="$1"
        shift
        local cmd_string="$*"
        [ -z "$cmd_string" ] \
            && return
        cmd_string="$(
            bash -c "set -o noglob; printf '%s\n' $cmd_string"
        )" || return
        IFS=$'\n' read -d '' -ra nameref < <(
            printf '%s\n' "$cmd_string"
            printf '\0'
        )
    }
fi

if Plan::import 'ok'; then
    # Usage: utils.ok [OPTION ...] EXIT_CODE [EXIT_CODE ...]
    #
    # Propagates non-zero EXIT_CODE if not in ignore list.
    #
    # Positional Args:
    #   EXIT_CODE  One or more exit codes separated by a space to check against
    #              an ignore list.
    #
    # Options:
    #   -i, --ignore  Comma-separated list of exit codes to ignore when
    #                 evaluating EXIT_CODE.
    #
    Plan::utils.ok() {
        local -a ignore
        while :; do
            case "$1" in
                -i | --ignore)
                    IFS=, read -ra ignore <<< "$2"
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
        local code
        for code in "$@"; do
            if ((code > 0)) && [[ " ${ignore[*]} " != *" $code "* ]]; then
                return "$code"
            fi
        done
        return 0
    }
fi

if Plan::import 'hr'; then
    # Print horizontal row with optional ANSI escape colors and header

    # Usage: utils.hr [COLOR_FG:COLOR_BG] [HEADER]
    #
    # Print horizontal row with optional ansi escape colors and header.
    #
    # Positional Args:
    #   COLORS  Background and foreground colors as ANSI color codes deliniated
    #           by a single colon, e.g., '176:212'.
    #   HEADER  An optional header to display in the center of the line.
    #
    Plan::utils.hr() {
        local bg="${1%:*}"
        local fg="${1#*:}"
        local header="$2"
        local color_end='\033[0m'

        local -i cols i
        cols="$(tput cols)"
        (("${#header}" > cols)) \
            && header="${header::cols-1}-"
        local -i header_len="${#header}"
        local -i hr_len=cols-header_len
        local -i hr_llen=hr_len/2
        local -i hr_rlen=hr_len-hr_llen

        local hr="\033[0;38;5;${bg:-15}m"
        for ((i = 0; i < hr_llen; i++)); do hr+="$PLAN__UI_HR_CHAR"; done
        if [ -n "$header" ]; then
            hr+="\033[38;5;${fg:-0};48;5;${bg:-15}m$header"
            hr+="\033[0;38;5;${bg:-15}m"
        fi
        for ((i = 0; i < hr_rlen; i++)); do hr+="$PLAN__UI_HR_CHAR"; done

        printf '%b%b\n' "$hr" "$color_end"
    }
fi

if Plan::import 'md5'; then
    # Usage: utils.md5 INPUT
    #
    # Return the md5 hash of a given INPUT using md5sum or non-zero exit code.
    #
    # Positional Args:
    #   INPUT  The input string to hash.
    #
    Plan::utils.md5() {
        [ -z "$1" ] && return 1
        (
            set -o pipefail
            md5sum <<< "$1" | cut -d' ' -f1
        )
    }
fi

if Plan::import 'sha1'; then
    # Usage: utils.sha1 INPUT
    #
    # Return the sha1 hash of a given INPUT using sha1sum or non-zero exit code.
    #
    # Positional Args:
    #   INPUT  The input string to hash.
    #
    Plan::utils.sha1() {
        [ -z "$1" ] && return 1
        (
            set -o pipefail
            sha1sum <<< "$1" | cut -d' ' -f1
        )
    }
fi

if Plan::import 'sha256'; then
    # Usage: utils.sha256 INPUT
    #
    # Return the sha256 hash of a given INPUT using sha256sum or non-zero exit code.
    #
    # Positional Args:
    #   INPUT  The input string to hash.
    #
    Plan::utils.sha256() {
        [ -z "$1" ] && return 1
        (
            set -o pipefail
            sha256sum <<< "$1" | cut -d' ' -f1
        )
    }
fi

if Plan::import 'depth2indent'; then
    # Usage: utils.depth2indent DEPTH TAB_LEN
    #
    # Calculates and prints N-spaced indentation based on some depth value and
    # a given tab length (spaces per depth).
    #
    # Positional Args:
    #   DEPTH    A multiplier that defines how my tabs are printed.
    #   TAB_LEN  The number of spaces that defines a tab.
    #
    Plan::utils.depth2indent() {
        local -i depth="$1"
        local -i tab_len="$2"
        local -i total="${depth} * ${tab_len}"
        [ "$total" -gt 0 ] \
            && printf "%-${total}s" ' '
    }
fi

if Plan::import '+color'; then
    readonly PLAN__BG='\033[48;5;@m'
    readonly PLAN__FG='\033[38;5;@m'
    readonly PLAN__CLR='\033[0m'
fi

Plan::import.clean
