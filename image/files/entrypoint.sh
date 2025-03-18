#!/usr/bin/env bash
set -Eeuo pipefail

source "/functions/is_contains.sh"

declare config=/etc/msmtprc
declare config_template=$config.template
declare -a args=()
declare success_phrase=
declare subject=

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

main
