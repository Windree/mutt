#!/bin/env bash
set -Eeuo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/functions/is_contains.sh"

declare -a args=
success_phrase=

while [ $# -gt 0 ]; do
  case "$1" in
  --success)
    shift
    success_phrase=$1
    if [ $# -gt 0 ]; then
      shift
    fi
    ;;
  -s)
    shift
    subject=$1
    if [ $# -gt 0 ]; then
      shift
    fi
    ;;
  *)
    args+=($1)
    shift
    ;;
  esac
done

dir=$(dirname "$(readlink -f -- "$0")")
mutt_image=$(basename "$dir")-dar
if [ -t 0 ]; then
  unset -v pipe
else
  pipe=$(cat -)
fi

function main() {
  build_image "$dir/image" "$mutt_image"
  if [ -v pipe ]; then
    local subj=$subject
    if [ -n "$success_phrase" ]; then
      subj=$(is_contains "$pipe" "$success_phrase" && echo "$subject ✓" || echo "$subject ⚠")
    fi
    echo "$pipe" | docker run --rm -i --env-file="$dir/.env" "$mutt_image" -s "$subj" "${args[@]}"
  else
    docker run --rm -it --env-file="$dir/.env" "$mutt_image" -s "$subject" "${args[@]}"
  fi
}

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
main
