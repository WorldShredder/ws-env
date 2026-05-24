#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

NODE_VERSION='24'
NODE_NVM_VERSION='0.40.4'
NODE_PURGE='false'

while [ $# -gt 0 ]; do
    case "$1" in
        --node-version)
            NODE_VERSION="$2"
            shift
            ;;
        --node-nvm-version)
            NODE_NVM_VERSION="$2"
            shift
            ;;
        --node-purge | --purge)
            NODE_PURGE='true'
            ;;
        --node-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

#
# Environment
#

Plan::vcache.add local NODE_VERSION "$NODE_VERSION"
Plan::vcache.add local NODE_NVM_VERSION "$NODE_NVM_VERSION"

if command -v nvm || command -v node; then
    if [ "$NODE_PURGE" != 'true' ]; then
        Plan::log.mod 'Skipping'
        Plan::vcache.add local NODE_SKIP_INSTALL true
        exit 0
    fi
fi

#
# Remove Install
#

Plan::log.mod 'Purging nvm, node, npm'

pkg_remove nodejs
[ -e "$NVM_DIR" ] \
    && rm -rf "$NVM_DIR"

IFS=' ' read -ra shells <<< "$WSE__SHELLS"
for sh in "${shells[@]}"; do
    if [ "$sh" = 'bash' ]; then
        sed -i '/.*NVM_DIR.*/d' "${HOME}/.bashrc" || true
    elif [ "$sh" = 'zsh' ]; then
        sed -i '/.*NVM_DIR.*/d' "${HOME}/.zshrc" || true
    fi
done

Plan::log.mod ' '
