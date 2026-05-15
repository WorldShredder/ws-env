#!/usr/bin/env bash

for f in "${PLAN__PATH_MODULE_DIR}/bootstrap.d/"*; do source "$f"; done

if [ "$GOLANG_PURGE" = 'true' ]; then
    Plan::log.mod 'Removing golang package'
    pkg_remove 'golang'

    Plan::log.mod 'Removing golang from system'
    sudo rm -rf \
        /usr/local/go \
        /usr/local/bin/go \
        /usr/bin/go \
        "$GOLANG_INSTALL_DIR"/go
    if command -v go &> /dev/null; then
        golang_path="$(command -v go)"
        [ -e "$golang_path" ] \
            && sudo rm -rf "$golang_path"
    fi
fi

# curl -L "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
#     | sudo -u "$GOLANG_OWNER" tar -xzC "$GOLANG_INSTALL_DIR"

curl -L "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    > "$PLAN__PATH_CACHE"

# export PATH="${GOLANG_INSTALL_DIR}/go/bin:${PATH}"
