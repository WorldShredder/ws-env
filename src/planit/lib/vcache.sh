#!/usr/bin/env bash

#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/logging.sh" --component logger
source "${PLAN__PATH_ROOT}/lib/utils.sh" --component sha256

#
# Library
#

PLAN__VCACHE_ROOT_ID=''
PLAN__VCACHE_LOCAL_ID=''

# Usage: vcache.add SCOPE NAME VALUE
Plan::vcache.add() {
    Plan::vcache.handler 'add' "$@"
}
export -f 'Plan::vcache.add'

# Usage: vcache.del SCOPE NAME VALUE
Plan::vcache.del() {
    Plan::vcache.handler 'del' "$@"
}
export -f 'Plan::vcache.del'

# Usage: vcache.clear SCOPE
Plan::vcache.clear() {
    Plan::vcache.handler 'clr' "$1"
}
export -f 'Plan::vcache.clear'

Plan::vcache.load() {
    Plan::vcache.handler 'load' "$@"
}

Plan::vcache.handler() {
    local op="${1^^}" env='false' set='false'
    shift

    while :; do
        case "$1" in
            -e | --env) env='true' ;;
            -s | --set) set='true' ;;
            --)
                shift
                break
                ;;
            *) break ;;
        esac
        shift
    done

    local scope="${1^^}" name="$2"
    shift 2
    value="$*"

    local path
    case "$scope" in
        G | GLOBAL) path="$PLAN__PATH_VCACHE_GLOBAL" ;;
        R | ROOT) path="${PLAN__PATH_VCACHE_ROOT}/${PLAN__VCACHE_ROOT_ID}" ;;
        L | LOCAL) path="${PLAN__PATH_VCACHE_LOCAL}/${PLAN__VCACHE_LOCAL_ID}" ;;
        *) return 1 ;;
    esac

    if [ -n "$name" ] && ! Plan::vcache.verify_name "$name"; then
        Plan::log.error "vcache: invalid var name '$(printf '%q' "$name")'"
        return 1
    fi

    local vpath="${path}/${name}"

    case "$op" in
        ADD)
            if [ -n "${name// /}" ]; then
                # Plan::log.debug "vcache: '$scope' add '$name' (path: '$vpath')"
                printf '%s' "$value" > "$vpath" || return 1
                if [ "$env" = 'true' ]; then
                    export "${name}=${value}" || {
                        Plan::log.error "vcache: failed to export '$name'"
                        return 1
                    }
                elif [ "$set" = 'true' ]; then
                    declare -g "${name}=${value}" || {
                        Plan::log.error "vcache: failed to set '$name'"
                        return 1
                    }
                fi
            fi
            ;;
        DEL)
            if [ -f "$vpath" ]; then
                # Plan::log.debug "vcache: '$scope' del '$name' (path: '$vpath')"
                rm "$vpath" || return 1
                [ "$env" = 'true' ] \
                    && unset "$name" 2> /dev/null || true
            fi
            ;;
        CLR)
            if [ -d "$path" ]; then
                # Plan::log.debug "vcache: clearing '$scope' at '$path'"
                ( # maybe use glob remove: rm "$path"/*
                    shopt -s nullglob
                    for f in "$path"/*; do
                        [ "$env" = 'true' ] \
                            && unset "$name" 2> /dev/null || true
                        rm "$f" || return 1
                    done
                )
            fi
            ;;
        LOAD)
            ! [ -d "$path" ] \
                && return 1

            local f value
            Plan::log.debug "vcache: scanning '$scope'"
            for f in "$path"/*; do
                name="${f##*/}"
                if Plan::vcache.verify_name "$name" && [ -f "$f" ]; then
                    Plan::log.debug "vcache: loading '$name' from '$scope'"
                    value="$(< "$f")" && export "$name"="$value" || {
                        Plan::log.error "vcache: failed to load '$name' from '$scope'"
                        return 1
                    }
                fi
            done
            ;;
        *) return 1 ;;
    esac
}
export -f 'Plan::vcache.handler'

Plan::vcache.verify_name() {
    [[ "$1" =~ [a-zA-Z_]+[a-zA-Z0-9_]* ]]
}
export -f 'Plan::vcache.verify_name'

Plan::vcache.update() {
    [ "$PLAN__ENABLE_VCACHE" != 'true' ] \
        && return

    if [ -z "$PLAN__VCACHE_ROOT_ID" ]; then
        local path="$PLAN__PATH_MODULES"
        PLAN__VCACHE_ROOT_ID="$(Plan::vcache.generate_id "$path")" || return 1
        PLAN__VCACHE_LOCAL_ID="$(Plan::vcache.generate_id "$path")" || return 1
        return 0
    fi

    Plan::vcache.update_local || return 1
    Plan::vcache.update_root || return 1
}

Plan::vcache.update_root() {
    # Root vcache is the first directory layer within the modules dir
    local -a arr
    IFS=/ read -ra arr <<< "${PLAN__PATH_MODULE_DIR#*"$PLAN__PATH_MODULES"}"
    local path v
    for v in "${arr[@]}"; do
        [ -z "${v// /}" ] \
            && continue
        path="${PLAN__PATH_MODULES}/${v}"
        break
    done

    # We may be in the base modules directory
    [ -z "$path" ] \
        && path="$PLAN__PATH_MODULES"

    local root_id root_path
    root_id="$(Plan::vcache.generate_id "$path")" || return 1
    root_path="${PLAN__PATH_VCACHE_ROOT}/${root_id}"

    if [ "$root_id" != "$PLAN__VCACHE_ROOT_ID" ] || ! [ -e "$root_path" ]; then
        PLAN__VCACHE_ROOT_ID="$root_id"
        if ! [ -d "$root_path" ]; then
            mkdir -p "$root_path" || return 1
            Plan::log.debug "vcache: new 'root' id '$root_id' (path: '$root_path')"
        else
            Plan::log.debug "vcache: 'root' returning to '$root_id'"
        fi
    fi
    return 0
}

Plan::vcache.update_local() {
    local local_id local_path
    local_id="$(Plan::vcache.generate_id "$PLAN__PATH_MODULE_DIR")"
    local_path="${PLAN__PATH_VCACHE_LOCAL}/${local_id}"
    if [ "$local_id" != "$PLAN__VCACHE_LOCAL_ID" ] || ! [ -e "$local_path" ]; then
        PLAN__VCACHE_LOCAL_ID="$local_id"
        if ! [ -d "$local_path" ]; then
            mkdir -p "$local_path" || return 1
            Plan::log.debug "vcache: new 'local' id '$local_id' (path: '$local_path')"
        else
            Plan::log.debug "vcache: 'local' returning to '$local_id'"
        fi
    fi
    return 0
}

Plan::vcache.generate_id() {
    local path="$1"
    (
        set -o pipefail
        Plan::utils.sha256 "$path" | head -c 16
    )
}
