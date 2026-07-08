#!/bin/bash

set -euo pipefail

GITLAB_HOST="${GITLAB_HOST:?not defined}"

function get_project_id_from_repo {
  local projectID

  projectID="$(git config remote.origin.url \
    | sed -En '/^([[:alpha:]]*:\/\/[[:alnum:]@.:]*\/|[[:alnum:]-]*:)([^\/]*)\/(.*)$/ s//\2%2F\3/;s#/#%2F#g;p')"
  projectID="${projectID%.git}"
  if [[ -z "$projectID" ]] ; then
    echo "Failed to extract project ID from 'git config remote.origin.url'" >&2
    exit 1
  fi
  echo "$projectID"
}

function query_lint_api {
  local -r projectID="${1:?arg1 is project ID}"
  local -r branch="${2:?arg2 is branch}"
  local -r file="${3:?arg3 is the file to lint}"

  curl -fsSL --request POST \
    --url "https://$GITLAB_HOST/api/v4/projects/$projectID/ci/lint" \
    --header "PRIVATE-TOKEN: ${GITLAB_TOKEN:?GITLAB_TOKEN not set}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    -d @<(jq -Rs --arg ref "$branch" '{ref: $ref, content: .}' "$file")
}

function lint {
  local -r projectID="${1:?arg1 is project ID}"
  local -r branch="${2:?arg2 is branch}"
  local -r file="${3:?arg3 is the file to lint}"

  query_lint_api "$projectID" "$branch" "$file" \
    | jq -r '. | if .valid == true then .valid | halt_error(0) else .errors | halt_error(1) end'
}

function needs_arg {
  if [[ -z "$OPTARG" ]]; then
    echo -e "\nERROR: No arg for --$flag option\n" >&2
    usage
  fi
}

function usage {
  cat <<EOF >&2
Usage: $(basename -- "$0") [options] <file>

 -p project   - Gitlab project to lint file for (default is read from 'git config remote.origin.url')
 -b branch    - branch (default is current branch)
 -m           - output merged yaml instead of linting

# create a Personal Access Token with at least scope 'api'
# https://$GITLAB_HOST/-/user_settings/personal_access_tokens
#
# https://docs.gitlab.com/ee/api/lint.html
EOF

  exit "${1:-1}"
}

function handle_options {
  while getopts "b:hmp:-:" flag; do
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$flag" = "-" ]; then   # long option: reformulate flag and OPTARG
      flag="${OPTARG%%=*}"       # extract long option name
      OPTARG="${OPTARG#"$flag"}" # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    case "$flag" in
      b | branch) needs_arg ; branch="$OPTARG" ;;
      h | help ) usage 0 ;;
      m ) outputMergedYaml="true" ;;
      p | project-id ) needs_arg ; projectID="$OPTARG" ;;
      *) usage ;;
    esac
  done
  shift $((OPTIND - 1))
  file="${1:-}"
  if [[ -z "$file" ]] ; then
    echo -e "\nERROR: no file specified.\n" >&2
    usage
  fi
}

function main {
  local branch projectID file
  local outputMergedYaml="false"
  branch="$(git describe --contains --all HEAD)"
  projectID="$(get_project_id_from_repo)" 

  handle_options "$@"

  if [[ "$outputMergedYaml" == "true" ]] ; then
    query_lint_api "$projectID" "$branch" "$file" \
      | jq -r '.merged_yaml'
  else
    lint "$projectID" "$branch" "$file"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
