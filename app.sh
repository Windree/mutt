#!/usr/bin/env bash
set -euo pipefail

declare root="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
source "$root/image/_/functions/string_hash.sh"
declare mutt_image=mutt-$(string_hash $root)
declare pipe=

if [ -t 0 ]; then
  unset -v pipe
else
  pipe=$(cat -)
fi

function build_image() {
  if ! docker build --quiet "$1" -t "$2" 2>/dev/null >/dev/null; then
    echo "Error build '$root/image'"
    exit 1
  fi
}

build_image "$root/image" "$mutt_image"

if [ -v pipe ]; then
  echo "$pipe" | docker run --rm -i -v "$root/config/msmtprc:/etc/msmtprc" "$mutt_image" "$@"
else
  docker run --rm -it "$mutt_image" "$@"
fi
