#!/usr/bin/env bash

docker run \
  --rm -i \
  rcjsuen/docker-langserver \
  -- \
  --stdio "$@"
