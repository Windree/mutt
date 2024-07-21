#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/image/_/functions/string_hash.sh"

dir=$(dirname "$(readlink -f -- "$0")")
mutt_image=mutt-$(string_hash $dir)
pipe=

if [ -t 0 ]; then
  unset -v pipe
else
  pipe=$(cat -)
fi

function build_image() {
  if ! docker build --quiet "$1" -t "$2" 2>/dev/null >/dev/null; then
    echo "Error build '$dir/image'"
    exit 1
  fi
}

function validate() {
  if [ ! -f "$dir/.env" ]; then
    echo "Unable to configuraton .env file."
    exit 1
  fi
}

validate

build_image "$dir/image" "$mutt_image"

if [ -v pipe ]; then
  echo "$pipe" | docker run --rm -i --env-file="$dir/.env" "$mutt_image" "$@"
else
  docker run --rm -it --env-file="$dir/.env" "$mutt_image" "$@"
fi
