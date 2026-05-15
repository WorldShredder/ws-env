#!/usr/bin/env bash

set -eo pipefail
trap 'exit 1' ERR

GOLANG_VERSION='1.26.0'
GOLANG_UPDATE='false'
GOLANG_PURGE='false'
GOLANG_INSTALL_DIR="${HOME}/.local/opt"
GOLANG_GOPATH="${HOME}/.local/go"
