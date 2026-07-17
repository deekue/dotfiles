#!/bin/bash
#

set -euo pipefail

readonly DEFAULT_BIN_PATH="$HOME/.local/bin"

function usage {
  cat <<EOF >&2
Usage: $(basename -- "$0") [options]

Options:
 -a       - update all
 -b       - binary to update
 -p       - binary path (default: $DEFAULT_BIN_PATH)
 -h       - help

EOF

  exit "${1:-1}"
}

function handle_options {
  while getopts "ab:c:hp:" flag; do
    case "$flag" in
      a) updateAll="true" ;;
      b) updateBinary="$OPTARG" ;;
      c) configFile="$OPTARG" ;;
      h) usage 0 ;;
      p) binPath="$OPTARG" ;;
      *) usage ;;
    esac
  done
  if [[ "$updateAll" == false ]] && [[ -z "${updateBinary:-}" ]] ; then
    echo 'ERROR: must specify one of -a or -b' >&2
    exit 1
  fi
  if [[ -z "${configFile:-}" ]] ; then
    configFile="$(dirname -- "$(readlink -e "${BASH_SOURCE[0]}")")/updateable-binaries.json"
  fi
}

function update {
  local -r binName="${1:?arg1 is binary name}"
  local -r releaseUrl="${2:?arg2 is release URL}"
  local -r binPath="${3:?arg3 is binary path}"

  local binLink currentVersion downloadUrl newVersionFile releaseJson version
  binLink="$binPath/$binName"
  releaseJson="$(curl -sSL "$releaseUrl")"

  version="$(jq -r .name <<< "$releaseJson")"
  newVersionFile="$binPath/$binName-$version"
  if [[ -z "$version" ]] ; then
    echo "ERROR: failed to extract version from $releaseUrl"
    return 1
  fi
  # TODO handle selecting gnu when present, instead of !musl
  downloadUrl="$(jq -r --arg ARCH "$(uname -m)" --arg platform "$(uname -s)" '.assets[] | select( .browser_download_url | contains($ARCH) ) | select(.browser_download_url | ascii_downcase | contains($platform|ascii_downcase)) | select(.browser_download_url|ascii_downcase | contains("musl")|not) | .browser_download_url' <<< "$releaseJson")"

  if [[ ! -f "$newVersionFile" ]] ; then
    tempFile="$(mktemp)"
    curl -fsSL "$downloadUrl" \
      | tar -xzO "$binName" \
      > "$tempFile"
    if [[ -s "$tempFile" ]] ; then
      mv "$tempFile" "$newVersionFile"
      chmod 0555 "$newVersionFile"
    else
      echo "ERROR: download failed for $downloadUrl" >&2
      return 1
    fi
  fi

  if [[ -L "$binLink" ]] ; then
    currentVersion="$(readlink -e "$binLink" | xargs -r basename | sed -En '/^.*-(v?[0-9.]+)$/ s//\1/p')"
    if [[ -z "$currentVersion" ]] ; then
      echo "ERROR: failed to extract current version from $binLink" >&2
      return 1
    fi
    if [[ "$version" == "$currentVersion" ]] ; then
      return 0
    fi
  fi
  ln -svf "$newVersionFile" "$binLink"
}

function main {
  local configFile data updateBinary
  local binPath="$DEFAULT_BIN_PATH"
  local updateAll="false"
  local -A binDict sites
  local -a binaries
  handle_options "$@"

  data="$(jq -r '.sites | to_entries | map("[\(.key|@sh)]=\(.value|@sh)")|.[]' "$configFile")"
  declare -A sites="($data)"

  if [[ "$updateAll" == "true" ]] ; then
    readarray -t binaries < <(jq -rc '.binaries[]' "$configFile")
  else
    readarray -t binaries < <(jq -rc --arg name "$updateBinary" '.binaries[] | select(.name == $name)' "$configFile")
    if [[ -z "${binaries[*]}" ]] ; then
      echo "ERROR: $updateBinary not found in $configFile" >&2
      exit 1
    fi
  fi

  for binConfig in "${binaries[@]}" ; do
    data="$(jq -r '. | to_entries | map("[\(.key|@sh)]=\(.value|@sh)")|.[]' <<< "$binConfig")"
    declare -A binDict="($data)"
    echo "${binDict[name]}"
    site="${binDict[site]}"
    # shellcheck disable=SC2059
    update "${binDict[name]}" "$(printf "${sites[$site]}" "${binDict[repo]}")" "$binPath"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
