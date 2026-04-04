#!/bin/zsh
# Generalized agent polling loop — see doc/agent_loop_spec.md

BASE=${BASE:-~/20260404}
POLL_INTERVAL=${POLL_INTERVAL:-30}
HANDLER=${HANDLER:-}

# ── validate required argument ────────────────────────────────────────────────

if [[ $# -lt 1 || -z "$1" ]]; then
  echo "ERROR: AGENT argument is required. Usage: agent_loop.sh <agent_name>" >&2
  exit 1
fi

AGENT=$1
INBOX="$BASE/$AGENT/inbox"
READ_DIR="$INBOX/read"
LOG="$BASE/$AGENT/${AGENT}_loop.log"

# ── validate inbox exists ─────────────────────────────────────────────────────

if [[ ! -d "$INBOX" ]]; then
  echo "ERROR: Inbox directory does not exist: $INBOX" >&2
  exit 1
fi

# ── helpers ───────────────────────────────────────────────────────────────────

log() {
  local event=$1
  local detail=$2
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $event: $detail" >> "$LOG"
}

# ── startup ───────────────────────────────────────────────────────────────────

mkdir -p "$READ_DIR"
log "STARTED" "agent=$AGENT poll_interval=${POLL_INTERVAL}s handler=${HANDLER:-none}"

# ── graceful shutdown ─────────────────────────────────────────────────────────

shutdown() {
  log "STOPPED" "agent=$AGENT"
  exit 0
}
trap shutdown TERM INT

# ── polling loop ──────────────────────────────────────────────────────────────

while true; do
  for filepath in "$INBOX"/*.md(N); do
    [[ -f "$filepath" ]] || continue
    filename=$(basename "$filepath")
    dest="$READ_DIR/$filename"

    mv "$filepath" "$dest"
    log "RECEIVED" "$filename"

    if [[ -n "$HANDLER" && -x "$HANDLER" ]]; then
      "$HANDLER" "$dest"
      local handler_rc=$?
      log "HANDLER" "$filename exit=$handler_rc"
    fi
  done

  sleep "$POLL_INTERVAL" &
  wait $!
done
