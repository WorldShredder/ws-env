#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

GOLANG_VERSION='1.26.0'
GOLANG_UPDATE='false'
GOLANG_PURGE='false'
GOLANG_INSTALL_DIR="${HOME}/.local/opt"
GOLANG_GOPATH="${HOME}/.local/go"

while [ $# -gt 0 ]; do
    case "$1" in
        --golang-update)
            GOLANG_UPDATE='true'
            ;;
        --golang-purge | --purge)
            GOLANG_PURGE='true'
            ;;
        --golang-version)
            GOLANG_VERSION="$2"
            shift
            ;;
        --golang-install-dir)
            GOLANG_INSTALL_DIR="$2"
            shift
            ;;
        --golang-gopath)
            GOLANG_GOPATH="$2"
            shift
            ;;
        --golang-*)
            Plan::log.mod -c 1 "Invalid option '$1'"
            exit 1
            ;;
    esac
    shift
done

#
# Environment
#

# TODO Define environment after purging & install check (see rust prepare)
Plan::vcache.add local GOLANG_VERSION '1.26.0'
Plan::vcache.add local GOLANG_INSTALL_DIR "$GOLANG_INSTALL_DIR"
Plan::vcache.add local GOLANG_GOPATH "$GOLANG_GOPATH"

if command -v go; then
    if [ "$GOLANG_UPDATE" = 'false' ] && [ "$GOLANG_PURGE" = 'false' ]; then
        Plan::log.mod "Skipping"
        Plan::vcache.add local GOLANG_SKIP_INSTALL true
        exit 0
    fi
fi

#
# Install Directory
#

Plan::log.mod "Checking install path '$GOLANG_INSTALL_DIR'"
if ! [ -e "$GOLANG_INSTALL_DIR" ]; then
    mkdir -p "$GOLANG_INSTALL_DIR" || sudo mkdir -p "$GOLANG_INSTALL_DIR"
elif ! [ -d "$GOLANG_INSTALL_DIR" ]; then
    Plan::log.mod -c 1 "${0##*/}: Install path not a directory '$GOLANG_INSTALL_DIR'"
    exit 1
fi

Plan::log.mod "Getting install path owner"
Plan::vcache.add -s local GOLANG_OWNER "$(sudo stat -c '%U' "$GOLANG_INSTALL_DIR")"

#
# Remove Install
#

declare -a rm_targets
if [ "$GOLANG_PURGE" = 'true' ]; then
    Plan::log.mod "Purging golang"
    rm_targets+=("${GOLANG_INSTALL_DIR}/go")
    rm_targets+=("$(command -v go 2> /dev/null || true)")
    rm_targets+=('/usr/local/go')
    rm_targets+=('/usr/bin/go')
    rm_targets+=("$(go env GOPATH 2> /dev/null || true)")
    pkg_remove golang
else
    Plan::log.mod "Updating golang"
    rm_targets+=("${GOLANG_INSTALL_DIR}/go")
fi

for f in "${rm_targets[@]}"; do
    [ -e "$f" ] \
        && sudo rm -rf "$f"
done

Plan::log.mod ' '
