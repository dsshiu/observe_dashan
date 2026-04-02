# Cross-communication protocol

One file: `/MM-DD0/queue.md`. Append only, never delete.

Entry format:

[HH:MM] FROM: {name} TO: {name} PRIORITY: {normal | blocking}

FRAME: {explore | solve}

{message body}

ACK: {recipient writes their name and time when they have read and will act}

Rules:
- Odie reads all entries regardless of addressee
- Recipient must write ACK before acting
- Blocking priority means recipient acts on next poll, interrupting current work
- Normal priority means recipient acts when current task reaches a natural pause
- No agent interprets a message addressed to another agent and acts on it unilaterally


Poll interval: once per minute for all agents.

Escalation rule:

Peter is the only agent who writes TO: Dashan. All others escalate to Peter first. Peter decides whether it reaches Dashan.
