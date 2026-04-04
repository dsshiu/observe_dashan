#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"
BASE_DIR="$(dirname "$0")"

mkdir -p "$BASE_DIR/$USERNAME/inbox"
mkdir -p "$BASE_DIR/$USERNAME/outbox"

echo "Created $USERNAME/inbox and $USERNAME/outbox"
