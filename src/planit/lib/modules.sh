#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

#
# Dependencies
#

source "${PLAN__PATH_ROOT}/lib/utils.sh" --component md5
source "${PLAN__PATH_ROOT}/lib/logging.sh" --component logger

#
# Globals
#

# Number of executable modules in PLAN__MODULES[] array
declare -i PLAN__NUM_MODULES

# Stores the module index relative to the value of PLAN__NUM_MODULES
declare -i PLAN__MODULE_INDEX

#
# Library
#

# Usage: modules.fetch MODULES_PATH [DEPTH]
#
# Populates an array with modules to execute.
#
# Positional Args:
#   MODULES_PATH   Path to the directory containing modules to collect.
#   DEPTH          The directory depth of the module; 0 if not set.
#
# Return:
#   Exit code 1 on disallowed symlink
#
Plan::modules.fetch() {
    local src="$1"
    local -i depth="${2:-0}"

    [ -z "${PLAN__MODULES:++}" ] \
        && PLAN__MODULES=()

    local path init_path
    # catch init in source root modules directory
    if init_path="$(Plan::modules.fetch_init "$src")"; then
        PLAN__NUM_MODULES+=1
        PLAN__MODULES+=("${depth}|${init_path}")
        return
    fi
    for path in "$src"/*; do
        if [ -L "$path" ] && [ "$PLAN__MODULES_SYMLINKS" != 'true' ]; then
            Plan::log.error "Symlinks not allowed '$path'"
            return 1
        fi
        if [ -d "$path" ]; then
            [ -f "${path}/.planitignore" ] \
                && continue
            if init_path="$(Plan::modules.fetch_init "$path")"; then
                PLAN__NUM_MODULES+=1
                PLAN__MODULES+=("${depth}|${init_path}")
            else
                PLAN__MODULES+=("${depth}|${path}")
                Plan::modules.fetch "$path" "$((depth + 1))" || return 1
            fi
        elif [ -f "$path" ] && ! [[ "$path" =~ \.(txt|conf|config|yml|yaml|json)$ ]]; then
            PLAN__NUM_MODULES+=1
            PLAN__MODULES+=("${depth}|${path}")
        fi
    done

    return 0
}

# Usage: modules.fetch_init PATH
#
# Search a given directory and return the first module init file found. Valid
# init file names are anything that starts with "init" or "init.*".
#
# Positional Args:
#   PATH  Path to a module directory.
#
# Return:
#   Full path to the init file or error code (1) if no init file is found.
Plan::modules.fetch_init() {
    local path="$1"
    local f
    ! [ -d "$path" ] \
        && return 1
    for f in "${path}"/*; do
        ! [ -f "$f" ] \
            && continue
        f="${f##*/}"
        if [ "${f%%.*}" = 'init' ]; then
            printf '%s' "${path}/${f}"
            return 0
        fi
    done
    return 1
}

# Usage: modules.format_title MODULE_PATH
#
# Formats the title of a given module or returns a default title.
#
# Positional Args:
#   MODULE_PATH  The path of the module to derive the title from. If the module
#                file name is a non-title name (e.g. init.sh) then format_title()
#                will scan the parent directory's name.
#
# Return:
#   Formatted title or empty string if last member of MODULE_PATH or its parent
#   directory fail regex match.
#
Plan::modules.format_title() {
    local name="${1##*/}"
    if [ "$name" == 'init.sh' ]; then
        # In this case we want to get the directory name
        name="${1%/*}"
        name="${name##*/}"
    fi
    local -a title
    if [[ "$name" =~ ^[0-9]+_\[ ]] && [[ "$name" =~ \](\.[a-zA-Z0-9]+)?$ ]]; then
        name="${name#*\[}"
        name="${name%]*}"
        local -i i
        local char next_char _title
        for ((i = 0; i < "${#name}"; i++)); do
            char="${name:i:1}"
            next_char="${name:i+1:1}"
            if [ "$char" == '%' ]; then
                _title+="$next_char"
                i+=1
            elif [ "$char" == '_' ]; then
                _title+=' '
            else
                _title+="$char"
            fi
        done
        read -ra title <<< "$_title"
    elif [[ "$name" =~ ^[0-9]+_.+$ ]]; then
        name="${name#*_}"
        name="${name%.*}"
        local sub l r
        while read -rd_ sub; do
            l="${sub::1}"
            r="${sub:1}"
            title+=("${l^^}${r,,}")
        done <<< "${name}_"
    fi
    printf '%s' "${title[*]}"
}

# Usage: modules.get_config MODULE_PATH
#
# Retrieve a module config from a given path.
#
# Positional Args:
#   MODULE_PATH  Path to a module or module directory containing a planit.conf
#                or module.conf file.
#
# Return:
#   Exit code (1) on disallowed symlink or config path.
#
Plan::modules.get_config() {
    local path="$1"
    local config
    if [ -e "$path" ]; then
        [ -f "$path" ] \
            && path="${path%/*}"
        if [ -f "${path}/module.conf" ]; then
            config="${path}/module.conf"
        elif [ -f "${path}/planit.conf" ]; then
            config="${path}/planit.conf"
        fi
    fi
    if [ -L "$config" ] && [ "$PLAN__MODULES_SYMLINKS" != 'true' ]; then
        Plan::log.error "Symlinks not allowed '$config'"
        return 1
    fi
    printf '%s' "$config"
}

# Usage: modules.generate_state_hash SALT
#
# Generates a state hash from PLAN__STATE_ID, PLAN__MODULES members and an
# optional salt. PLAN__MODULES member paths are converted to relative paths
# to provide deterministic hashes regardless of installer location.
#
# Positional Args:
#   SALT  Ideally, a deterministic value to add as a prefix before hashing.
#
# Return:
#   The state hash string or last exit code from hash function.
#
Plan::modules.generate_state_hash() {
    local salt="$1"
    local modules_joined module
    for module in "${PLAN__MODULES[@]}"; do
        modules_joined+=${module#*"$PLAN__PATH_MODULES"}
    done
    local state_id="${PLAN__STATE_ID}${modules_joined}"
    [ -n "$state_id" ] \
        && Plan::utils.md5 "${salt}${state_id}"
}

# Usage: modules.generate_module_hash MODULE_PATH
#
# Generates a state hash of a module by passing MODULE_PATH as the salt of
# the generate_state_hash() function.
#
# Positional Args:
#   MODULE_PATH  Path of the module to hash. This should be a member of
#                the PLAN__MODULES array.
#
# Return:
#   The module state hash string or last exit code from hash function.
#
Plan::modules.generate_module_hash() {
    # Relative module path to prevent losing state when moving install dir
    local module="${1#*"$PLAN__PATH_MODULES"/}"
    Plan::modules.generate_state_hash "$module"
}

# Usage: modules.save_state MODULE_PATH
#
# Hash given module and store state in state file.
#
# Positional Args:
#   MODULE_PATH  Path of the module to store.
#
# Return:
#   Exit code (1) on error or (0).
#
Plan::modules.save_state() {
    local module state
    module="$1"
    if ! state="$(Plan::modules.generate_module_hash "$1")"; then
        Plan::log.error "Failed to generate module hash '$module'"
        return 1
    fi
    if ! printf '%s' "$state" > "$PLAN__PATH_STATE"; then
        Plan::log.error "Write to state file failed '$PLAN__PATH_STATE'"
        return 1
    fi
    return 0
}

# Usage: modules.fetch_state
#
# Returns current state hash in PLAN__PATH_STATE or exit code (1) on error.
#
Plan::modules.fetch_state() {
    local state
    state="$(cat "$PLAN__PATH_STATE" 2> /dev/null)" \
        || return 1
    printf '%s' "$state"
}

# Usage: modules.fetch_state_idx
#
# Fetch and return the current state and get its index in PLAN__MODULES.
# Return exit code (1) on error.
#
Plan::modules.fetch_state_idx() {
    local i state module_hash
    local -i state_idx=0
    state="$(Plan::modules.fetch_state)" || return 1
    for ((i = 0; i < "${#PLAN__MODULES[@]}"; i++)); do
        module_hash="$(Plan::modules.generate_module_hash "${PLAN__MODULES[$i]}")" \
            || return 1
        if [ "$state" == "$module_hash" ]; then
            state_idx="$i"
            break
        fi
    done
    printf '%d' "$state_idx"
}

# Usage: modules.fetch_rel_idx MODULE
#
# Fetch the module's index relative to the number of modules. This function
# is necessary since PLAN__MODULES contains directories as well.
#
# Positional Args:
#   MODULE  The module from PLAN__MODULES to get the index of.
#
Plan::modules.fetch_rel_idx() {
    local module="$1"
    local -i idx=0
    local m _ path
    for m in "${PLAN__MODULES[@]}"; do
        IFS=\| read -r _ path <<< "$m"
        ! [ -d "$path" ] \
            && idx+=1
        [ "$m" == "$module" ] \
            && break
    done
    printf '%d' "$idx"
}
