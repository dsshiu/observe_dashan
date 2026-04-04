#!/bin/zsh
# Tests for agent_loop.sh — derived from agent_loop_spec.md
# Run from any directory. Requires agent_loop.sh in ~/20260404/agent_loop.sh

set -euo pipefail

SCRIPT=~/20260404/agent_loop.sh
PASS=0
FAIL=0

# ── helpers ──────────────────────────────────────────────────────────────────

pass() { echo "  PASS: $1"; PASS=$(( PASS + 1 )); }
fail() { echo "  FAIL: $1"; FAIL=$(( FAIL + 1 )); }

# Create a temp workspace that looks like the real one
make_workspace() {
  local tmp=$(mktemp -d)
  local agent=$1
  mkdir -p "$tmp/$agent/inbox"
  echo "$tmp"
}

cleanup() { rm -rf "$1"; }

# Run agent_loop.sh for N seconds, then kill it; return its exit code
run_for() {
  local secs=$1; shift
  BASE="$1" POLL_INTERVAL=1 "$SCRIPT" "$2" &
  local pid=$!
  sleep "$secs"
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

# ── test 1: missing AGENT argument exits 1 ───────────────────────────────────

t1() {
  local out
  out=$("$SCRIPT" 2>&1) && local rc=$? || local rc=$?
  if [[ $rc -ne 0 ]]; then
    pass "exits non-zero when AGENT argument is missing"
  else
    fail "should exit non-zero when AGENT argument is missing (got $rc)"
  fi
}

# ── test 2: nonexistent inbox exits 1 ────────────────────────────────────────

t2() {
  local tmp=$(mktemp -d)
  local out rc
  out=$(BASE="$tmp" "$SCRIPT" nosuchagent 2>&1) && rc=$? || rc=$?
  rm -rf "$tmp"
  if [[ $rc -ne 0 ]]; then
    pass "exits non-zero when inbox directory does not exist"
  else
    fail "should exit non-zero when inbox does not exist (got $rc)"
  fi
}

# ── test 3: read/ directory created on startup ───────────────────────────────

t3() {
  local tmp=$(make_workspace testagent)
  run_for 2 "$tmp" testagent
  if [[ -d "$tmp/testagent/inbox/read" ]]; then
    pass "creates inbox/read/ on startup"
  else
    fail "inbox/read/ was not created"
  fi
  cleanup "$tmp"
}

# ── test 4: startup log entry written ────────────────────────────────────────

t4() {
  local tmp=$(make_workspace testagent)
  run_for 2 "$tmp" testagent
  local logfile="$tmp/testagent/testagent_loop.log"
  if [[ -f "$logfile" ]] && grep -q "STARTED" "$logfile"; then
    pass "writes STARTED entry to log on startup"
  else
    fail "no STARTED entry in log (log exists: $([[ -f $logfile ]] && echo yes || echo no))"
  fi
  cleanup "$tmp"
}

# ── test 5: new message is moved to read/ ────────────────────────────────────

t5() {
  local tmp=$(make_workspace testagent)
  # Drop a message before starting the loop
  echo "hello" > "$tmp/testagent/inbox/sender_to_testagent_001.md"
  run_for 3 "$tmp" testagent
  local moved=0 original=0
  [[ -f "$tmp/testagent/inbox/read/sender_to_testagent_001.md" ]] && moved=1
  [[ -f "$tmp/testagent/inbox/sender_to_testagent_001.md" ]]      && original=1
  if [[ $moved -eq 1 && $original -eq 0 ]]; then
    pass "message moved from inbox to inbox/read/"
  else
    fail "message not moved correctly (in read/: $moved, still in inbox: $original)"
  fi
  cleanup "$tmp"
}

# ── test 6: RECEIVED entry logged for each message ───────────────────────────

t6() {
  local tmp=$(make_workspace testagent)
  echo "hello" > "$tmp/testagent/inbox/sender_to_testagent_001.md"
  run_for 3 "$tmp" testagent
  local logfile="$tmp/testagent/testagent_loop.log"
  if grep -q "RECEIVED" "$logfile" 2>/dev/null; then
    pass "RECEIVED entry written to log for new message"
  else
    fail "no RECEIVED entry in log"
  fi
  cleanup "$tmp"
}

# ── test 7: message not re-processed after move ──────────────────────────────

t7() {
  local tmp=$(make_workspace testagent)
  echo "hello" > "$tmp/testagent/inbox/sender_to_testagent_001.md"
  run_for 4 "$tmp" testagent
  local logfile="$tmp/testagent/testagent_loop.log"
  local count
  count=$(grep -c "RECEIVED" "$logfile" 2>/dev/null || echo 0)
  if [[ $count -eq 1 ]]; then
    pass "message processed exactly once (no re-processing)"
  else
    fail "RECEIVED logged $count times, expected 1"
  fi
  cleanup "$tmp"
}

# ── test 8: handler is invoked with path in read/ ────────────────────────────

t8() {
  local tmp=$(make_workspace testagent)
  local handler_out="$tmp/handler_called.txt"

  # Create a simple handler that records its argument
  local handler="$tmp/handler.sh"
  cat > "$handler" <<'EOF'
#!/bin/zsh
echo "$1" >> "$HANDLER_OUT"
EOF
  chmod +x "$handler"

  echo "hello" > "$tmp/testagent/inbox/sender_to_testagent_001.md"
  HANDLER_OUT="$handler_out" BASE="$tmp" POLL_INTERVAL=1 HANDLER="$handler" "$SCRIPT" testagent &
  local pid=$!
  sleep 3
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true

  if [[ -f "$handler_out" ]] && grep -q "inbox/read" "$handler_out"; then
    pass "handler invoked with path inside inbox/read/"
  else
    fail "handler not called with read/ path (handler_out exists: $([[ -f $handler_out ]] && echo yes || echo no))"
  fi
  cleanup "$tmp"
}

# ── test 9: handler non-zero exit is logged, loop continues ──────────────────

t9() {
  local tmp=$(make_workspace testagent)

  local handler="$tmp/handler.sh"
  cat > "$handler" <<'EOF'
#!/bin/zsh
exit 42
EOF
  chmod +x "$handler"

  echo "msg1" > "$tmp/testagent/inbox/sender_to_testagent_001.md"
  echo "msg2" > "$tmp/testagent/inbox/sender_to_testagent_002.md"
  BASE="$tmp" POLL_INTERVAL=1 HANDLER="$handler" "$SCRIPT" testagent &
  local pid=$!
  sleep 3
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true

  local logfile="$tmp/testagent/testagent_loop.log"
  local handler_entries
  handler_entries=$(grep -c "HANDLER" "$logfile" 2>/dev/null || echo 0)
  if [[ $handler_entries -ge 2 ]]; then
    pass "loop continues after handler non-zero exit (both messages processed)"
  else
    fail "expected >=2 HANDLER log entries, got $handler_entries"
  fi
  cleanup "$tmp"
}

# ── test 10: STOPPED entry on graceful shutdown ───────────────────────────────

t10() {
  local tmp=$(make_workspace testagent)
  run_for 2 "$tmp" testagent
  local logfile="$tmp/testagent/testagent_loop.log"
  if grep -q "STOPPED" "$logfile" 2>/dev/null; then
    pass "STOPPED entry written to log on shutdown"
  else
    fail "no STOPPED entry in log"
  fi
  cleanup "$tmp"
}

# ── run all tests ─────────────────────────────────────────────────────────────

echo ""
echo "=== agent_loop.sh tests ==="
echo ""

for t in t1 t2 t3 t4 t5 t6 t7 t8 t9 t10; do
  echo "[$t]"
  $t
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
