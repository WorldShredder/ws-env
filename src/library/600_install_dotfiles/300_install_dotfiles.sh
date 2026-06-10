#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

if [ "$DOTFILES_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

cd "${DOTFILES_DL_PATH}/lib"

IFS=, read -ra library_targets <<< "${DOTFILES_LIBRARY:-"$(
    find . -mindepth 1 -maxdepth 1 -type d | tr '\n' ','
)"}"

for lib in "${library_targets[@]}"; do
    lib="${lib//.\//}"
    with_sudo='false'
    declare -a lib_args=()
    case "$lib" in
        ps1) with_sudo='true' ;;
        nvim)
            required=('cppcheck')
            [ "$WSE__DISTRIB" = 'debian' ] \
                && required+=('python3-venv')
            Plan::log.mod "Installing '$lib' dependencies: ${required[*]}"
            pkg_install "${required[@]}"
            ;;
        base16)
            lib_args+=('--theme' "$DOTFILES_SHELL_THEME")
            ;;
    esac

    Plan::log.mod "Installing '$lib'"
    if [ "$with_sudo" = 'true' ]; then
        sudo "${lib}/src/install" "${lib_args[@]}"
    else
        "${lib}/src/install" "${lib_args[@]}"
    fi
done

Plan::log.mod 'Cleaning up'
cd ../.. && rm -rf "$DOTFILES_DL_PATH"

Plan::log.mod ' '
