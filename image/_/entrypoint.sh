#!/usr/bin/env bash
set -Eeuo pipefail

source "/functions/is_contains.sh"

dir=$(dirname "$(readlink -f -- "$0")")
config=/etc/msmtprc
config_template=$config.template
declare -a args=
success_phrase=
subject=

if [ -t 1 ]; then
  unset pipe
else
  pipe=$(cat -)
fi

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

function main() {
  cat "$config_template" >"$config"
  create_config >>"$config"
  local subj=$subject
  if [ -n "$success_phrase" ]; then
    subj=$(echo -n "$subject "; is_contains "$pipe" "$success_phrase" && echo "✓" || echo "⚠")
  fi
  if [ -v pipe ]; then
    echo "$pipe" | mutt -s "$subj" "${args[@]}"
  else
    mutt -s "$subj" "${args[@]}"
  fi

}

function create_config() {
  local error=0
  if require_string from; then
    echo "from $from"
  else
    error=1
  fi
  if require_string smtp_host; then
    echo "host $smtp_host"
  else
    error=1
  fi
  if require_string smtp_port; then
    echo "port $smtp_port"
  else
    error=1
  fi
  if require_boolean smtp_tls; then
    echo "tls $smtp_tls"
  else
    error=1
  fi
  if require_boolean smtp_auth; then
    echo "auth $smtp_auth"
    if [ -v user ]; then
      echo "user $user"
    else
      echo "'user' required if smtp_auth=on 1>&2." 1>&2
      error=1
    fi
    if [ -v password ]; then
      echo "password $password"
    else
      echo "'password' required if smtp_auth=on." 1>&2
      error=1
    fi
  else
    error=1
  fi
  if [ $error -ne 0 ]; then
    exit 1
  fi
}

function require_boolean() {
  if [ ! -v ${1} ]; then
    echo "'${1}' required." 1>&2
    return 1
  fi
  if ! [[ ${!1} =~ ^(on|off)$ ]]; then
    echo "'${1}' must be 'on' or 'off'. Currently '${!1}'." 1>&2
    return 1
  fi
}

function require_string() {
  if [ ! -v ${1} ]; then
    echo "'${1}' required." 1>&2
    return 1
  fi
  if [ -z ${!1} ]; then
    echo "'${1}' required non empty string" 1>&2
    return 1
  fi
}

function cleanup() {
  rm -f "$config"
}

trap cleanup EXIT HUP INT QUIT PIPE TERM

main
