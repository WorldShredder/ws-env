#!/usr/bin/env bash

if ! [ -e "$GOLANG_INSTALL_DIR" ]; then
    mkdir -p "$GOLANG_INSTALL_DIR" || sudo mkdir -p "$GOLANG_INSTALL_DIR"
elif ! [ -d "$GOLANG_INSTALL_DIR" ]; then
    Plan::log.error "${0##*/}: Install path not a directory '$GOLANG_INSTALL_DIR'"
    exit 1
fi

GOLANG_OWNER="$(sudo stat -c '%U' "$GOLANG_INSTALL_DIR")"

if [ "$GOLANG_UPDATE" = 'true' ] || [ "$GOLANG_PURGE" = 'true' ]; then
    sudo rm -rf "$GOLANG_INSTALL_DIR/go"
fi
