#!/bin/bash
#
# based on
# https://www.macintoshhowto.com/pages-and-publishing/how-to-print-to-a-pdf-booklet-in-os-x-mojave.html
#
# To combine the pages into a booklet go to ‘Print’ the document and then
# select these 3 options under ‘Layout’:
#
# ‘2 Pages per sheet’
# ‘Two-Sided’
# ‘Short-Edge binding’
#

set -eEuo pipefail

if [[ "$(uname -s)" != "Darwin" ]] ; then
  echo "Warning: only tested on MacOS" >&2
fi

# check for required tools
if ! type pdfinfo > /dev/null ; then
  echo -e "pdfinfo not found\nbrew install poppler" >&2
  exit 1
fi
if ! type convert > /dev/null ; then
  echo -e "convert not found\nbrew install imagemagick" >&2
  exit 1
fi

src="${1:?arg1 is source pdf}"
dst="${src%%.pdf}-booklet.pdf"
srcFileName="$(basename -- "$src")"
tempDir="$(mktemp -d)"
baseDstName="$tempDir/${srcFileName%%.pdf}"

# how many pages do we have
numPages="$(pdfinfo "$src" | sed -En '/^Pages: *([0-9]*)/ s//\1/p')"

# booklet must have numPages % 4
numBlanks="$(( 4 - numPages % 4 ))"

# create blank page(s)
if [[ "$numBlanks" -gt 0 ]] ; then
  firstBlank="$((numPages + 1))"
  lastBlank="$((firstBlank + numBlanks - 1))"
  for i in $(seq "$firstBlank" "$lastBlank") ; do
    echo "creating blank page ${baseDstName}-$i.pdf"
    convert xc:none -page Letter "${baseDstName}-$i.pdf"
  done
  lastPage="$lastBlank"
else
  lastPage="$numPages"
fi

# split pdf into pages, in temp dir
pdfseparate "$src" "${baseDstName}-%d.pdf"

# generate booklet order
i="$lastPage"
j=1
numPairs="$((lastPage / 2))"
declare -a pages
for n in $(seq 1 $numPairs) ; do
  if [[ "$(( n % 2 ))" -eq 0 ]] ; then
    pages+=("${baseDstName}-$j.pdf")
    pages+=("${baseDstName}-$i.pdf")
  else
    pages+=("${baseDstName}-$i.pdf")
    pages+=("${baseDstName}-$j.pdf")
  fi
  i=$(( i - 1 ))
  j=$(( j + 1 ))
done

# create new pdf
pdfunite "${pages[@]}" "$dst"

cat <<EOF
Generated $dst

Open the file then select ‘Print’ and then select these 3 options under ‘Layout’:
  - ‘2 Pages per sheet’
  - ‘Two-Sided’
  - ‘Short-Edge binding’
EOF

