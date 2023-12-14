#!/bin/env bash
set -Eeuo pipefail

dir=$(dirname "$(readlink -f -- "$0")")
config=/etc/msmtprc
if [ -t 1 ]; then
  unset pipe
else
  pipe=$(cat -)
fi

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

if [ -v pipe ]; then
  echo "$pipe" | mutt "$@"
else
  mutt "$@"
fi
