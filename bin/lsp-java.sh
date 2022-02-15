#!/usr/bin/env bash

set -eEuo pipefail

BASE_LSP_DIR="${BASE_LSP_DIR:-$HOME/.lsp}"
JAVA_LSP_LOG="$HOME/.local/share/lsp-java.log"
JAVA_LSP_NAME="eclipse.jdt.ls"
JAVA_LSP_DIR="${JAVA_LSP_DIR:-$BASE_LSP_DIR/$JAVA_LSP_NAME}"
JAVA_LSP_VER="1.1.0"
JAVA_LSP_URL="http://download.eclipse.org/jdtls/milestones/$JAVA_LSP_VER"
JAVA_LSP_CACHE="$HOME/.cache/$JAVA_LSP_NAME"

case "$(uname -o)" in
  Darwin)
    JAVA_LSP_CFG=config_mac
    ;;
  Linux)
    JAVA_LSP_CFG=config_linux
    ;;
  # TODO Windows?
  *)
    echo "Unsupported platform: $(uname -o)" >&2
    exit 1
esac

# if dir missing, install
if [[ ! -d "$JAVA_LSP_DIR" ]] ; then
  mkdir -p "$JAVA_LSP_DIR"
  pushd "$JAVA_LSP_DIR"
  dlFilename="$(curl -fsSL "$JAVA_LSP_URL/latest.txt")"
  curl -fsSL "$JAVA_LSP_URL/$dlFilename" | tar xzf -
  popd
fi
mkdir -p "$JAVA_LSP_CACHE"

# Launcher version doesn't match JDTLS version
JAVA_LSP_LAUNCHER="$(ls $JAVA_LSP_DIR/plugins/org.eclipse.equinox.launcher_*.jar )"

java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.level=NONE \
  -Dlog.protocol=true \
  -noverify \
  -Dfile.encoding=UTF-8 \
  -Xmx1G \
  -jar "$JAVA_LSP_LAUNCHER" \
  -configuration "$JAVA_LSP_DIR/$JAVA_LSP_CFG" \
  -data "$JAVA_LSP_CACHE" \
  >> "$JAVA_LSP_LOG" \
  2>> "$JAVA_LSP_LOG"
