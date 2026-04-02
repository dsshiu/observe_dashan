# Self-communication protocol

Each agent maintains one self-log file in `/MM-DD/` named after themselves — peter.md, odie.md, etc. They are the sole writer of their own file.

Entry format:

[HH:MM] [working | blocked | flagging | done]

Did: {one line}

Next: {one line}

Flag: {anything that feels off, or empty}

Rules:
- Append only, never overwrite
- Write after every meaningful action, at minimum every 5 minutes during active work
- flagging and blocked status are the only entries Odie treats as interrupts
