# Cross-communication protocol

One file: `/MM-DD/queue.md`. Append only, never delete.

Entry format:

```
[HH:MM] FROM: {name} TO: {name} PRIORITY: {normal | blocking}
FRAME: {explore | solve}
{message body}
ACK: {recipient writes their name and time when they have read and will act}
```

Rules:

* Odie reads all entries regardless of addressee
* Recipient must write ACK before acting
* Blocking priority means recipient acts on next poll, interrupting current work
* Normal priority means recipient acts when current task reaches a natural pause
* No agent interprets a message addressed to another agent and acts on it unilaterally

Poll interval: once per minute for all agents.

---

## Escalation rule

Peter is the only agent who writes TO: Dashan. All others escalate to Peter first. Peter decides whether it reaches Dashan.

**Early experimental period — strengthened escalation:**
Peter should escalate to Dashan liberally. Over-escalation is cheap. Under-escalation is expensive. When Peter is uncertain whether Dashan needs to be involved, assume yes.

---

## [DASHAN] tag

Any step in `plan.md` that requires Dashan's input or decision must be tagged `[DASHAN]`.

Rules:

* Peter must stop and write TO: Dashan PRIORITY: blocking when the team reaches a `[DASHAN]` step
* No agent may proceed past a `[DASHAN]` step without a confirmed Dashan ACK in `queue.md`
* Odie watches for any agent proceeding past a `[DASHAN]` step without ACK — this is a tripwire and Odie flags it to Peter immediately as PRIORITY: blocking
* Peter may add `[DASHAN]` tags to plan.md during execution if unexpected branch points emerge

---

## Dashan check-in

In the early experimental period, Dashan checks in with Peter at a regular cadence (suggested: every 30 minutes) rather than waiting to be called. This compensates for the absence of a push notification mechanism. Peter should have a brief status summary ready at each check-in.
