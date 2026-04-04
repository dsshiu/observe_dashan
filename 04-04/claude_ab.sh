#!/bin/bash
# claude_ab.sh — A/B branching exploration for Claude Code
#
# WORKFLOW
# --------
# 1. Session A runs to a natural checkpoint.
#    A calls:  ./claude_ab.sh --checkpoint
#    This saves A's session ID and current line count, then prints
#    the command to start B.
#
# 2. A exits (type /exit or Ctrl-C).
#
# 3. In a new terminal, start B using the printed command:
#    claude --resume <session_id>
#    B explores freely, then exits.
#
# 4. Back in the original terminal, run:
#    ./claude_ab.sh --resume-a
#    This:
#      a. Extracts B's appended lines as a conversation transcript
#      b. Truncates the session file back to A's checkpoint
#      c. Injects the transcript as a synthetic user message
#      d. Resumes A via: claude --resume <session_id>
#    A wakes up at its checkpoint state, with B's full exploration
#    delivered as its next prompt.
#
# NOTES
# -----
# - Run both commands from the same working directory (the project root).
# - The checkpoint is stored in .claude_checkpoint.json in the current directory.
# - claude --resume appends to the same .jsonl file, which is why truncation
#   is needed to restore A's state before resuming.

set -euo pipefail

CHECKPOINT_FILE=".claude_checkpoint.json"

# Derive the Claude projects subdirectory name from the current working directory.
# Claude Code uses: leading slash stripped, remaining slashes replaced with hyphens.
get_project_dir() {
    pwd | sed 's|^/||; s|/|-|g'
}

# ─── --checkpoint ────────────────────────────────────────────────────────────

cmd_checkpoint() {
    local project_dir
    project_dir=$(get_project_dir)
    local sessions_dir="$HOME/.claude/projects/$project_dir"

    if [ ! -d "$sessions_dir" ]; then
        echo "ERROR: Sessions directory not found: $sessions_dir" >&2
        exit 1
    fi

    # The newest .jsonl file is the currently active session (A).
    # This is reliable when called while A is still running.
    local session_file
    session_file=$(ls -t "$sessions_dir"/*.jsonl 2>/dev/null | head -1)
    if [ -z "$session_file" ]; then
        echo "ERROR: No session files found in $sessions_dir" >&2
        exit 1
    fi

    python3 - "$session_file" "$CHECKPOINT_FILE" <<'PYEOF'
import json, sys

session_file = sys.argv[1]
checkpoint_file = sys.argv[2]

with open(session_file) as f:
    lines = f.readlines()

# Session ID is in the first record that carries a sessionId field.
session_id = None
for line in lines:
    try:
        d = json.loads(line)
        if 'sessionId' in d:
            session_id = d['sessionId']
            break
    except Exception:
        pass

if not session_id:
    print("ERROR: Could not find sessionId in session file", file=sys.stderr)
    sys.exit(1)

checkpoint = {
    'session_id': session_id,
    'line_count': len(lines),
    'session_file': session_file
}

with open(checkpoint_file, 'w') as f:
    json.dump(checkpoint, f, indent=2)

print(f"Checkpoint saved.")
print(f"  Session ID  : {session_id}")
print(f"  Line count  : {len(lines)}")
print()
print(f"Now exit this session, then start B with:")
print(f"  claude --resume {session_id}")
print()
print(f"When B has finished and exited, restore A with:")
print(f"  ./claude_ab.sh --resume-a")
PYEOF
}

# ─── --resume-a ──────────────────────────────────────────────────────────────

cmd_resume_a() {
    if [ ! -f "$CHECKPOINT_FILE" ]; then
        echo "ERROR: No checkpoint file ($CHECKPOINT_FILE) found in current directory." >&2
        echo "Run ./claude_ab.sh --checkpoint from within session A first." >&2
        exit 1
    fi

    python3 - "$CHECKPOINT_FILE" <<'PYEOF'
import json, sys, os, uuid as uuidlib
from datetime import datetime, timezone

checkpoint_file = sys.argv[1]

with open(checkpoint_file) as f:
    checkpoint = json.load(f)

session_id    = checkpoint['session_id']
checkpoint_n  = checkpoint['line_count']   # A's line count at checkpoint
session_file  = checkpoint['session_file']

if not os.path.exists(session_file):
    print(f"ERROR: Session file not found: {session_file}", file=sys.stderr)
    sys.exit(1)

with open(session_file) as f:
    all_lines = f.readlines()

current_n = len(all_lines)

if current_n <= checkpoint_n:
    print(f"ERROR: No new lines since checkpoint "
          f"(current={current_n}, checkpoint={checkpoint_n}).", file=sys.stderr)
    print("Has B run and exited yet?", file=sys.stderr)
    sys.exit(1)

print(f"Session    : {session_id}")
print(f"Checkpoint : line {checkpoint_n}")
print(f"Current    : line {current_n}")
print(f"B's trace  : {current_n - checkpoint_n} lines")

# ── Extract B's conversation from the appended lines ──────────────────────────

a_lines = all_lines[:checkpoint_n]
b_lines = all_lines[checkpoint_n:]

parts = []
for raw in b_lines:
    raw = raw.strip()
    if not raw:
        continue
    try:
        d = json.loads(raw)
    except Exception:
        continue

    t = d.get('type')

    # User turns (skip meta/system injections)
    if t == 'user' and not d.get('isMeta'):
        content = d.get('message', {}).get('content', '')
        if isinstance(content, str):
            text = content.strip()
            if text:
                parts.append(f"[USER]: {text}")
        elif isinstance(content, list):
            for item in content:
                if not isinstance(item, dict):
                    continue
                if item.get('type') == 'text':
                    text = item.get('text', '').strip()
                    if text:
                        parts.append(f"[USER]: {text}")
                elif item.get('type') == 'tool_result':
                    r = item.get('content', '')
                    if isinstance(r, str) and r.strip():
                        parts.append(f"[TOOL RESULT]: {r[:1000]}")
                    elif isinstance(r, list):
                        for rb in r:
                            if isinstance(rb, dict) and rb.get('type') == 'text':
                                txt = rb.get('text', '').strip()
                                if txt:
                                    parts.append(f"[TOOL RESULT]: {txt[:1000]}")

    # Assistant turns
    elif t == 'assistant':
        for item in d.get('message', {}).get('content', []):
            if not isinstance(item, dict):
                continue
            if item.get('type') == 'text':
                text = item.get('text', '').strip()
                if text:
                    parts.append(f"[ASSISTANT]: {text}")
            elif item.get('type') == 'tool_use':
                name = item.get('name', '')
                inp  = json.dumps(item.get('input', {}))[:600]
                parts.append(f"[TOOL CALL: {name}]: {inp}")

b_transcript = '\n\n'.join(parts) if parts else "(B produced no readable output)"

# ── Find the UUID of A's last message (needed for parentUuid chain) ────────────

last_uuid = None
for raw in reversed(a_lines):
    try:
        d = json.loads(raw.strip())
        if 'uuid' in d:
            last_uuid = d['uuid']
            break
    except Exception:
        pass

# ── Build the synthetic user message carrying B's transcript ──────────────────

new_uuid = str(uuidlib.uuid4())
now      = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')

injection_content = (
    "[EXPLORATION BRANCH B — TRANSCRIPT]\n\n"
    "The following is the complete transcript of exploration session B, "
    "which branched from this checkpoint and has now exited. "
    "Please review B's findings and decide how to proceed.\n\n"
    "---\n\n"
    f"{b_transcript}\n\n"
    "---\n\n"
    "[END OF B TRANSCRIPT]"
)

injection = {
    "parentUuid":  last_uuid,
    "isSidechain": False,
    "type":        "user",
    "message": {
        "role":    "user",
        "content": injection_content
    },
    "uuid":        new_uuid,
    "timestamp":   now,
    "userType":    "external",
    "sessionId":   session_id
}

# ── Truncate file to A's checkpoint lines, then append injection ──────────────

with open(session_file, 'w') as f:
    f.writelines(a_lines)
    f.write(json.dumps(injection) + '\n')

print()
print("Session file restored to checkpoint.")
print("B transcript injected as next user message.")
print(f"Resuming session A ({session_id}) ...\n")

# Replace this process with claude --resume (clean exec, no subprocess wrapper)
os.execvp('claude', ['claude', '--resume', session_id])
PYEOF
}

# ─── Entry point ─────────────────────────────────────────────────────────────

case "${1:-}" in
    --checkpoint)
        cmd_checkpoint
        ;;
    --resume-a)
        cmd_resume_a
        ;;
    *)
        echo "Usage: $0 --checkpoint | --resume-a"
        echo ""
        echo "  --checkpoint   Save current session state (call from within session A)"
        echo "  --resume-a     After B exits: restore A, inject B transcript, resume A"
        exit 1
        ;;
esac
