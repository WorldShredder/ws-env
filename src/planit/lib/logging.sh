#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/utils.sh" --component +color

#
# Library
#

source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::log "$@"

if Plan::import 'logger'; then
    declare -A PLAN__LOG_LEVELS
    declare -A PLAN__LOG_ICONS
    declare -A PLAN__LOG_COLORS

    Plan::log.init() {
        PLAN__LOG_LEVEL="${PLAN__LOGGING_LEVEL:-INFO}"
        PLAN__CALLER_LEVEL="${PLAN__LOGGING_CALLER_LEVEL:-NONE}"

        PLAN__LOG_LEVELS[NONE]=0
        PLAN__LOG_LEVELS[ERROR]=1
        PLAN__LOG_LEVELS[WARN]=2
        PLAN__LOG_LEVELS[INFO]=3
        PLAN__LOG_LEVELS[DEBUG]=4

        PLAN__LOG_ICONS[ERROR]="$PLAN__LOGGING_ERROR_PREFIX"
        PLAN__LOG_ICONS[WARN]="$PLAN__LOGGING_WARN_PREFIX"
        PLAN__LOG_ICONS[INFO]="$PLAN__LOGGING_INFO_PREFIX"
        PLAN__LOG_ICONS[DEBUG]="$PLAN__LOGGING_DEBUG_PREFIX"

        PLAN__LOG_COLORS[ERROR]="${PLAN__FG//@/$PLAN__LOGGING_ERROR_COLOR}"
        PLAN__LOG_COLORS[WARN]="${PLAN__FG//@/$PLAN__LOGGING_WARN_COLOR}"
        PLAN__LOG_COLORS[INFO]="${PLAN__FG//@/$PLAN__LOGGING_INFO_COLOR}"
        PLAN__LOG_COLORS[DEBUG]="${PLAN__FG//@/$PLAN__LOGGING_DEBUG_COLOR}"

        # init
        local level icon color
        for level in "${!PLAN__LOG_LEVELS[@]}"; do
            [ "${PLAN__LOG_LEVELS[$level]}" -le 0 ] \
                && continue
            icon="${PLAN__LOG_ICONS[$level]}"
            [ -z "$icon" ] \
                && icon="$(printf '[%-5s]' "$level")"
            color="${PLAN__LOG_COLORS[$level]}"
            eval "Plan::log.${level,,}() { \
                      Plan::log.logger '${level}' '${icon}' '${color}' \"\$*\"; \
                  }"
            # export -f "Plan::log.${level,,}"
        done

        # shellcheck disable=SC2329
        Plan::log.logger() {
            local level="$1"
            local icon="$2"
            local color="$3"
            shift 3
            local message="$*"

            local global_level="${PLAN__LOG_LEVELS[$PLAN__LOG_LEVEL]}"
            local global_caller_level="${PLAN__LOG_LEVELS[$PLAN__CALLER_LEVEL]}"
            local local_level="${PLAN__LOG_LEVELS[$level]}"

            if [ "$local_level" -gt "$global_level" ] || [ "$global_level" -lt 1 ]; then
                return 0
            fi

            local caller
            [ "$local_level" -le "$global_caller_level" ] \
                && local caller="${FUNCNAME[2]}: "

            printf '%b%s %s%s\033[0m\n' "$color" "$icon" "$caller" "$message" >&2
        }

        # export -f 'Plan::log.logger'
        unset -f Plan::log.init
    }

    # initialize all loggers
    Plan::log.init
fi

if Plan::import 'mod'; then
    Plan::log.mod() {
        local color nocolor delay
        while :; do
            case "$1" in
                -c | --color)
                    color="\033[38;5;${2}m"
                    nocolor='\033[0m'
                    shift
                    ;;
                -d | --delay)
                    delay="$2"
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
        printf '%b%s%b\n' "$color" "$*" "$nocolor" >> "$PLAN__PATH_LOG_MOD"
        # must add delay for monitor loop 0.05s (fragile approach)
        sleep "${delay:-0.1}"
    }
    export -f Plan::log.mod
fi

Plan::import.clean
