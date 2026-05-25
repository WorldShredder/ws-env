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

if [ "$ZOXIDE_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install zoxide
else
    Plan::log.mod 'Running Zoxide install script'
    cd "$ZOXIDE_DL_PATH"
    rm -rf ./.git
    ./install

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$ZOXIDE_DL_PATH"
fi

Plan::log.mod "Configuring shells: $WSE__SHELLS"
IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    path="${HOME}/.shellrc.d/${sh}"

    if [ "$ZOXIDE_USE_PKGMAN" != 'true' ]; then
        name='300_zoxide_path.sh'
        printf '%s\n' \
            '! [[ "$PATH" == *"${HOME}/.local/bin"* ]] &&' \
            '    PATH="${HOME}/.local/bin:${PATH}"' \
            > "${path}/${name}"
    fi

    name='301_zoxide_init.sh'
    printf '%s\n' "eval \"\$(zoxide init $sh)\"" > "${path}/${name}"
done

Plan::log.mod ' '
