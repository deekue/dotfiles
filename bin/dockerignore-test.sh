#!/bin/bash

# Based on BMitch's answer from:
# https://stackoverflow.com/questions/38946683/how-to-test-dockerignore-file

# 1. Run script
# 2. You should see list of files in build context
# 3. If unwanted files in context, adjust .dockerignore file and go back to step 3

set -euo pipefail

dockerfile="$(mktemp)"

cat <<EOF > "$dockerfile"
FROM busybox
COPY . /build-context
WORKDIR /build-context
CMD ["find", "."]
EOF

docker build -f "$dockerfile" -t build-context .
docker run --rm -it build-context
