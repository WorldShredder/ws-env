#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$ZOXIDE_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

declare -a cargo_args
[ -n "$ZOXIDE_CARGO_ARGS" ] \
    && IFS=' ' read -ra cargo_args <<< "$ZOXIDE_CARGO_ARGS"

if [ "$ZOXIDE_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install zoxide
elif [ -n "$ZOXIDE_VERSION" ]; then
    Plan::log.mod "Installing version '$ZOXIDE_VERSION' via cargo-binstall"
    if [ "$ZOXIDE_VERSION" = 'latest' ]; then
        cargo binstall "${cargo_args[@]}" -y 'zoxide'
    else
        cargo binstall "${cargo_args[@]}" -y "zoxide@${ZOXIDE_VERSION}"
    fi
else
    Plan::log.mod 'Running Zoxide install script'
    cd "$ZOXIDE_DL_PATH"
    ./install.sh

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$ZOXIDE_DL_PATH"
fi

Plan::log.mod "Configuring shells: $WSE__SHELLS"
IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    if [ "$ZOXIDE_USE_PKGMAN" != 'true' ] && [ -z "$ZOXIDE_VERSION" ]; then
        name='300_zoxide_path.sh'
        printf '%s\n' \
            '! [[ "$PATH" == *"${HOME}/.local/bin"* ]] &&' \
            '    PATH="${HOME}/.local/bin:${PATH}"' \
            > "${WSE__SHELLRCD}/${name}"
    fi

    name="301_zoxide_init.${sh}"
    printf '%s\n' "eval \"\$(zoxide init $sh)\"" \
        > "${WSE__SHELLRCD}/${name}"
done

Plan::log.mod ' '
