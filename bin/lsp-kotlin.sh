#!/usr/bin/env bash

docker run \
 --rm -i \
 -e "ARTIFACTORY_USERNAME:${ARTIFACTORY_USERNAME:?ARTIFACTORY_USERNAME not set}" \
 -e "ARTIFACTORY_PASSWORD:${ARTIFACTORY_PASSWORD:?ARTIFACTORY_PASSWORD not set}" \
 -v "$HOME/Projects:$HOME/Projects" \
 "docker.pkg.github.com/fwcd/kotlin-language-server/server:0.8.2" \
 "/server/bin/kotlin-language-server" \
 "$@"
