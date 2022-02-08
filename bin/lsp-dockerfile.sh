#!/usr/bin/env bash

docker run \
  --name lsp_dockerfile \
  --rm -i \
  rcjsuen/docker-langserver \
  -- \
  --stdio "$@"
