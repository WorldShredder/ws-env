#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$FZF_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$FZF_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via ${WSE__DISTRIB} package manager"
    pkg_install fzf
    Plan::log.mod ' '
    exit 0
fi

#
# Install Binary
#

Plan::log.mod "Copying FZF to /usr/local/opt"

rm -rf "$FZF_DL_PATH/.git"
install_path="${HOME}/.local/opt"

mkdir -p "$install_path"
cp -r "$FZF_DL_PATH" "$install_path"

# Now we can setup runtime config and completions
Plan::log.mod 'Setting up completions'
"${install_path}/fzf/install" --all

Plan::log.mod 'Cleaning up'
rm -rf "$FZF_DL_PATH"

Plan::log.mod ' '
