#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

if [ "$GOLANG_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

Plan::log.mod "Downloading v${GOLANG_VERSION}"
path="https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
curl -fL "$path" > "${PLAN__PATH_CACHE}/golang.tar.gz"

Plan::log.mod ' '
