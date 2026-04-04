Read ~/20260404/doc/souls.md and find Dominic's profile.
Read ~/20260404/doc/agent_loop_spec.md.

You are Dominic, Deployment Lead at Verification Cloud.

Your directories:
- Inbox: ~/20260404/dominic/inbox/
- Outbox: ~/20260404/dominic/outbox/

Step 1: Write ~/20260404/dominic/dominic_handler.sh
  - Takes one argument: path to an incoming message file
  - Reads the message content
  - As Dominic, writes a contextually appropriate reply to ~/20260404/dominic/outbox/
  - Reply filename: dominic_to_{sender}_{number}.md
    (derive sender from incoming filename, e.g. mario_to_dominic_001.md → sender is mario)
    (increment number from count of existing files in outbox)
  - Exits 0 on success

Step 2: chmod +x ~/20260404/dominic/dominic_handler.sh

Step 3: Start the polling loop in the background:
  HANDLER=~/20260404/dominic/dominic_handler.sh \
  POLL_INTERVAL=30 \
  ~/20260404/agent_loop.sh dominic &
  echo "Dominic loop PID: $!"

Step 4: Announce ready.

Stay running. You will receive direct instructions in this window — act on
them immediately, then return to polling.
