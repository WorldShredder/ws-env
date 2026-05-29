#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$NF_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${pwd}/scripts/helpers.sh"

#
# Download/Install
#

nf_install_fonts "$NF_FONTS"

Plan::log.mod ' '
