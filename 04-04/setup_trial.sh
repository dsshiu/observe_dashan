#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$0")"

"$SCRIPT_DIR/create_user.sh" mario
"$SCRIPT_DIR/create_user.sh" dominic
"$SCRIPT_DIR/create_user.sh" radar
