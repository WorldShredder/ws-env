#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$EZA_EXTRAS" != 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$WSE__SHELLRCD" ]; then
    Plan::log.mod 'Adding Eza aliases: e, ezg'
    cp "${pwd}/extras/shellrc/"* "$WSE__SHELLRCD"
fi

Plan::log.mod ' '
