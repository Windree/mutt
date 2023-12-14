#!/bin/env bash
set -Eeuxo pipefail

args=("$@")
dir=$(dirname "$(readlink -f -- "$0")")
if [ -t 0 ]; then
  unset -v pipe
else
  pipe=$(cat -)
fi

function main() {
  local image=$(get_image_name "$dir/_/mutt.txt" mutt)
  build_image "$dir/image" "$image"
  if [ -v pipe ];then
    echo "$pipe" | docker run --rm -i --env-file="$dir/.env" "$image" "${args[@]}"
  else
    docker run --rm -it --env-file="$dir/.env" "$image" "${args[@]}"
  fi
}

function build_image() {
  if ! docker build --quiet "$1" -t "$2" 2>/dev/null >/dev/null; then
    echo "Error build '$dir/image'"
    exit 1
  fi
}

function get_image_name() {
  if [ -f "$1" ]; then
    cat "$1"
    return 0
  fi
  mkdir -p "$(dirname "$1")"
  echo -n $2-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1) | tee "$1"
}

function validate() {
  if [ ! -f "$dir/.env" ]; then
    echo "Unable to configuraton .env file."
    exit 1
  fi
}

validate
main
