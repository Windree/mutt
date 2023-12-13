#!/bin/env bash
set -Eeuo pipefail

args=("$@")
pipe=$(cat -)
dir=$(dirname "$(readlink -f -- "$0")")

function main() {
  local image=$(get_image_name "$dir/_/mutt.txt" mutt)
  build_image "$dir/image" "$image"
  echo "$pipe" | docker run --rm -i --env-file="$dir/.env" "$image" "${args[@]}"
}

function build_image() {
  if ! docker build --quiet "$1" -t "$2" 2>/dev/null >/dev/null; then
    echo "Error build '$dir/image'"
    exit 1
  fi
}

function get_image_name(){
  if [ -f "$1" ]; then
    cat "$1"
    return 0
  fi
  mkdir -p "$(dirname "$1")"
  echo -n $2-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1) | tee "$1"
}

function validate(){
  if [ ! -f "$dir/.env" ]; then
    echo "Unable to configuraton .env file."
    exit 1
  fi
}

validate
main
