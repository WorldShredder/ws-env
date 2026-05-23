#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NODE_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

Plan::log.mod 'Sourcing NVM environment'
source "${HOME}/.nvm/nvm.sh"

Plan::log.mod "Installing Node v${NODE_VERSION}"
nvm install "${NODE_VERSION}"

Plan::log.mod 'Confirming install'
node -v
npm -v

Plan::log.mod ' '
