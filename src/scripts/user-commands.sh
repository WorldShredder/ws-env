#!/usr/bin/env bash

run_user_command() {
    local command_name="$1"
    shift
    local command_path
    local user="${__USER__:-${SUDO_USER:-$USER}}"
    command_path="$(sudo -u "$user" bash -c "command -v '$command_name'")"
    [ -n "$command_path" ] \
        && sudo -u "$user" "$command_path" "$@"
}

user_mkdir() { run_user_command 'mkdir' "$@"; }
export -f user_mkdir

user_cp() { run_user_command 'cp' "$@"; }
export -f user_cp

user_tee() { run_user_command 'tee' "$@"; }
export -f user_tee

user_curl() { run_user_command 'curl' "$@"; }
export -f user_curl

user_tar() { run_user_command 'tar' "$@"; }
export -f user_tar

user_make() { run_user_command 'make' "$@"; }
export -f user_make

user_git() { run_user_command 'git' "$@"; }
export -f user_git

user_clone() { user_git clone --depth 1 "$@"; }
export -f user_clone
