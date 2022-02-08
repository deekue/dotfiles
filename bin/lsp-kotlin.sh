#!/usr/bin/env bash

set -eEuo pipefail

# https://github.com/fwcd/kotlin-language-server/releases
#KLS_DOCKER_REPO="docker.pkg.github.com"
KLS_DOCKER_IMAGE="fwcd/kotlin-language-server/server"
KLS_VERSION="latest"
KLS_DOCKER_URI="$KLS_DOCKER_IMAGE:$KLS_VERSION"

# local build
KLS_GIT_REPO="https://github.com/fwcd/kotlin-language-server"
KLS_SRC_DIR="$HOME/src/${KLS_GIT_REPO##*/}"

function buildKLS {
  cd "$KLS_SRC_DIR" \
    && docker buildx build -t "$KLS_DOCKER_IMAGE" .
}

# use local image if no repo set
if [[ -z "${KLS_DOCKER_REPO:-}" ]] ; then
  # pull down src code if not present
  if [[ ! -d "$KLS_SRC_DIR" ]] ; then
    mkdir -p "${KSL_SRC%/*}"
    cd "${KSL_SRC%/*}"
    git clone "$KLS_GIT_REPO"
    buildKLS
  elif [[ "${1:-}" == "update-local" ]] ; then
    cd "$KLS_SRC_DIR"
    git pull
    buildKLS
  fi
  localKlsImage="$(docker image ls -q "$KLS_DOCKER_IMAGE")"
  if [[ -z "$localKlsImage" ]] ; then
    buildKLS
  fi
else
  # prepend Docker repo, if set
  KLS_DOCKER_URI="$KLS_DOCKER_REPO/$KLS_DOCKER_URI"
fi

docker run \
  --name lsp_kotlin \
  --rm -i \
  -e "ARTIFACTORY_USERNAME:${ARTIFACTORY_USERNAME:?ARTIFACTORY_USERNAME not set}" \
  -e "ARTIFACTORY_PASSWORD:${ARTIFACTORY_PASSWORD:?ARTIFACTORY_PASSWORD not set}" \
  -v "$HOME/Projects:$HOME/Projects" \
  "${KLS_DOCKER_URI}" \
  "/server/bin/kotlin-language-server" \
  "$@"
