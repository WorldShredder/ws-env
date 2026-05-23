#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2016

set -eo pipefail
trap 'exit $?' ERR

declare -a required
case "$WSE__DISTRIB" in
    debian) required+=(curl git tar xz-utils unzip jq) ;;
    fedora) required+=(curl git tar xz unzip jq) ;;
    *) exit 1 ;;
esac

pkg_update
pkg_install "${required[@]}"
