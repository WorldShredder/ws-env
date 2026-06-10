#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$SESH_EXTRAS" != 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$WSE__SHELLRCD" ]; then
    Plan::log.mod 'Installing Sesh bindings and completions'
    IFS=' ' read -ra shells <<< "$WSE__SHELLS"
    for sh in "${shells[@]}"; do
        cp "${pwd}/extras/shellrc/"*".${sh}" "$WSE__SHELLRCD"

        if [ "$sh" = 'bash' ]; then
            path="${HOME}/.local/share/bash-completions/completions"
            mkdir -p "$path"
            sesh completion bash > "${path}/sesh"
        elif [ "$sh" = 'zsh' ]; then
            path="${HOME}/.zsh/completions"
            mkdir -p "$path"
            sesh completion zsh > "${path}/_sesh"
        fi
    done
fi

Plan::log.mod ' '
