#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NODE_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

Plan::log.mod "Installing NVM v${NODE_NVM_VERSION}"
curl -fo- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NODE_NVM_VERSION}/install.sh" | bash

Plan::log.mod ' '
