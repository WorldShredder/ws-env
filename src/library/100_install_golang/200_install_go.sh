#!/usr/bin/env bash

for f in "${PLAN__PATH_MODULE_DIR}/bootstrap.d/"*; do source "$f"; done

# curl -L "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
#     | sudo -u "$GOLANG_OWNER" tar -xzC "$GOLANG_INSTALL_DIR"

curl -L "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    > "${PLAN__PATH_CACHE}/go.tar.gz"

# export PATH="${GOLANG_INSTALL_DIR}/go/bin:${PATH}"
