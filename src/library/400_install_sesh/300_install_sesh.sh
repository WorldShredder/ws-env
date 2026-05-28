#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016,SC1090

set -eo pipefail
trap 'exit $?' ERR

if [ "$SESH_SKIP_INSTALL" = 'true' ]; then
    Plan::log.mod 'Skipping'
    exit 0
fi

#
# Install Package
#

if [ "$SESH_USE_PKGMAN" = 'true' ]; then
    Plan::log.mod "Installing via Go"
    go install sesh
else
    Plan::log.mod "Build/install via Go"
    cd "$SESH_DL_PATH"
    go install

    Plan::log.mod 'Cleaning up'
    cd .. && rm -rf "$SESH_DL_PATH"
fi

Plan::log.mod ' '
