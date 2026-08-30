#!/bin/sh
set -eu

# BusyBox/POSIX readlink lacks -f, use a portable directory change instead
current_dir=$(dirname "$0")
root=$(cd "$current_dir" && pwd -P)

# Standard md5/md5sum compatibility check
if command -v md5sum >/dev/null 2>&1; then
  hash_val=$(echo "$root" | md5sum | awk '{ print $1}')
elif command -v md5 >/dev/null 2>&1; then
  hash_val=$(echo "$root" | md5)
else
  # Fallback if no md5 tool is installed
  hash_val=$(echo "$root" | cksum | awk '{ print $1}')
fi

container_id="mutt-$hash_val"

if ! docker build --quiet "$root/image" -t "$container_id" >/dev/null 2>&1; then
  echo "Error build '$root/image'" >&2
  exit 1
fi

# Check if standard input is a TTY
if [ -t 0 ]; then
  docker run --rm --hostname mailer -it "$container_id" "$@"
else
  # Consume stdin into a variable to mimic the original Bash logic
  cat | docker run --rm --hostname mailer -i "$container_id" "$@"
fi
