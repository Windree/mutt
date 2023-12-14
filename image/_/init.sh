#!/bin/env bash
set -Eeuo pipefail

pipe=$(cat -)
dir=$(dirname "$(readlink -f -- "$0")")
config=/etc/msmtprc

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

function get_image_name() {
  if [ -f "$1" ]; then
    cat "$1"
    return 0
  fi
  mkdir -p "$(dirname "$1")"
  echo -n $2-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1) | tee "$1"
}

function create_config() {
  local error=0
  if [ -v host ]; then
    echo "host $host"
  else
    echo "'host' required." 1>&2
    error=1
  fi
  if [ -v port ]; then
    echo "port $port"
  else
    echo "'port' required." 1>&2
    error=1
  fi
  if [ -v from ]; then
    echo "from $from"
  else
    echo "'from' required." 1>&2
    error=1
  fi
  if [ -v tls ]; then
    if require_boolean tls; then
      echo "tls $tls"
    else
      error=1
    fi
  fi
  if [ -v auth ]; then
    if require_boolean auth; then
      echo "auth $auth"
    else
      error=1
    fi
  fi
  if [ -v user ]; then
    echo "user $user"
  else
    echo "'user' required if auth=on 1>&2." 1>&2
    error=1
  fi
  if [ -v password ]; then
    echo "password $password"
  else
    echo "'password' required if auth=on." 1>&2
    error=1
  fi
  if [ $error -ne 0 ]; then
    exit 1
  fi
}

function require_boolean() {
  if [[ ${!1} =~ ^(on|off)$ ]]; then
    return 0
  fi
  echo "'${1}' must be 'on' or 'off'. Currently '${!1}'." 1>&2
  return 1
}

function cleanup() {
  rm -f "$config"
}

trap cleanup exit

cat "$config".template >"$config"
create_config >>"$config"

echo -n "$pipe" | mutt "$@"
