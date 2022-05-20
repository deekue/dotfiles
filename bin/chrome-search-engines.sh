#!/usr/bin/env bash

set -eEuo pipefail

case "$(uname -s)" in
  Darwin)
    defaultChromeDB="$HOME/Library/Application Support/Google/Chrome/Default/Web Data"
    ;;
  Linux)
    defaultChromeDB="$HOME/.config/google-chrome/Default/Web Data"
    ;;
  *)
    echo "TODO: add support for $(uname -s)" >&2
    defaultChromeDB=
    ;;
esac

function usage {
  cat <<EOF >&2
Usage: ${BASH_SOURCE[0]##*/} <import|export> <sql file> [Chrome DB]

default Chrome DB: ${defaultChromeDB}
EOF
  exit 1
}

function exportSQL {
  local -r srcDB="${1:?arg1 is source DB}"
  local -r dstFile="${2:?arg2 is destination file}"
  selectQuery='SELECT short_name,keyword,url,favicon_url FROM keywords WHERE keyword NOT LIKE "%.%"'
  insertQuery='INSERT OR REPLACE INTO keywords (short_name, keyword, url, favicon_url) VALUES ("%s", "%s", "%s", "%s");\n'

  tmpDB="$(mktemp)"
  # TODO add trap to delete tmpDB

  # make copy as Chrome holds an exclusive lock
  cp "${srcDB}" "${tmpDB}"

  (
    printf 'begin transaction;\n'
    sqlite3 "${tmpDB}" "${selectQuery}" \
      | while IFS='|' read short_name keyword url favicon_url ; do
          printf "${insertQuery}" "${short_name}" "${keyword}" "${url}" "${favicon_url}" 
        done
    printf 'end transaction;\n'
  ) > "${dstFile}"
}


function importSQL {
  local -r srcFile="${1:?arg1 is source SQL file}"
  local -r dstDB="${2:?arg2 is dest DB}"

  if ! sqlite3 "${dstDB}" < "${srcFile}" ; then
    echo "Quit Chrome first" >&2
    return 1
  fi
}

function main {
  local -r op="${1:?arg1 is op}"
  local -r sqlFile="${2:?arg2 is sql file}"
  local -r chromeDB="${3:-"${defaultChromeDB}"}"

  case "${op}" in
    i|import)
      importSQL "${sqlFile}" "${chromeDB}"
      ;;
    e|export)
      exportSQL "${chromeDB}" "${sqlFile}"
      ;;
    *)
      usage
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
  [[ -z "${1:-}" ]] && usage
  [[ -z "${2:-}" ]] && usage
  main "$@"
fi
