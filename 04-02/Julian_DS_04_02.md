# Julian_DS_04_02

## 1. The Underlying Question

Good and fast progress on innovative achievements. Dashan is a scarce high-leverage resource. The goal is to remove Dashan as a bottleneck without removing Dashan as a force multiplier. This is not a delegation problem. It is an **attention routing and system observation problem**.

### 1.1 Logging

- Format: structured markdown, three sections only — concluded / deferred / unresolved
- Vessel: Julian_DS_MM_DD.md, named by date
- Repository: github.com/dsshiu/observe_dashan
- Emission: at natural session breakpoints, called by Julian not Dashan

### 1.2 Closing the Retrospection Loop

- Mechanism: a friction log — one line per observation that surfaces but isn't acted on
- Review cadence: every 4 hours during a session, and at end of day — Julian calls it, not Dashan
- Risk: backlog becomes graveyard without scheduled review

#### 1.2.1 Action Target Classification

When promoting a friction observation to action:

- Observation about **agent behavior** → `claude.md`
- Observation about **system structure** → architecture decision
- Observation about **Dashan's intent or knowledge** → persistent log
- Observation about **Dashan's working preferences** → `culture.md`

*First concrete action from this session: add topical hierarchy instruction to `claude.md`. Add culture document to Verification-Cloud repo root.*

### 1.3 Julian's Persistence Across Sessions

- Julian is Chat — cannot read Drive, cannot write to GitHub directly
- Julian reads prior session logs from GitHub at start of each session
- Dashan pastes the GitHub URL at cold start; Julian fetches and proceeds
- julian.md (Julian's standing instructions) should live in observe_dashan repo

---

## 2. Observation Gap Map (priority view)

High cost, easy to install — attack these first:

- Session summaries to persistent log (done today)
- Handoff logging between agents via queue.md (designed today)
- Agent emits status tag per turn (in souls.md)
- Intent restatement before acting (in souls.md)
- Explore vs. solve frame tag at prompt header (in cross-communication protocol)

High cost, hard to install — defer:

- Real-time mid-task intervention
- Autonomous circuit breaker without Dashan
- Push notification to Dashan (Telegram via OpenAI agent, Claude dispatch — research needed)

---

## 3. The Cohort — Designed Today

### 3.1 Roles as designed (v1 — known to be imperfect)

| Name    | Interface | Role                                              |
| ------- | --------- | ------------------------------------------------- |
| Julian  | Chat      | Frame-holder, meta-observer, retrospective caller |
| Peter   | Cowork    | Planner                                           |
| Odie    | Code      | Observer                                          |
| Charlie | Code      | Coder                                             |
| Tim     | Code      | Tester                                            |
| Diana   | Cowork    | Diagnostician                                     |
| Igor    | Code      | Integrator                                        |

### 3.2 Known problems with v1 composition

- Not SDD-TDD compatible. Correct composition should be researched, not invented.
- Sequential not concurrent — role isolation achieved context reduction but not parallelism.
- A more appropriate composition may be: Steven (spec governance), Charlie (CloudSim test+code+diagnosis), Charles (presim test+code+diagnosis), Ivan (end-to-end integration).

### 3.3 Infrastructure

- Shared drive: Google Drive mounted locally, accessible to all agents
- Coordination bus: queue.md in shared drive, append-only, polled once per minute
- Self-logs: one per agent, append-only, in shared drive date folder
- File flow: agents pull from predecessors, not push. Recipient initiates.
- Git: clean final record only. Charlie commits at end after Dashan confirms. Not during work.
- GitHub observe_dashan: durable session logs and protocol documents

### 3.4 Key protocol documents

- Self-communication protocol: github.com/dsshiu/observe_dashan/Self-communication protocol.md
- Cross-communication protocol: github.com/dsshiu/observe_dashan/Cross-communication-protocol.md
- Souls: shared drive MM-DD/souls.md (includes diary instruction)
- Culture: Verification-Cloud root/culture.md (to be created)

---

## 4. Today's Task — ex100_fifo End-to-End Run

### 4.1 What we set out to do

- Run obfuscation on presim/examples/ex100_fifo → produces Glymir.submit
- Transfer to dev/tests/examples/ex100_fifo
- Run all five vcloud_commands.sh commands sequentially
- Collect reports and HTML, fix every obstacle

### 4.2 Status at end of day

- Phase 1 (obfuscation) complete — Dashan ran presim Claude Code, fixed one issue (injection stripping order)
- plan.md produced by Peter, reviewed, revised twice
- Four issues remain in plan.md (Steps 4-6 underspecified, Igor scope ambiguous, Diana pull condition unclear, Odie absent from plan)
- Execution not started — carried to next session

### 4.3 Key decisions made

- NUM_TRANSACTIONS=100 for TEST_05 (not 1000)
- obfuscation_map.txt and sim_build/ never leave presim
- rtl/sync_fifo.sv was obfuscated in-place — Charlie must copy obfuscated version, not original
- dashan/ directory at ~/20260402/dashan for Dashan's experiment work
- Tim is Code not Cowork (can fix environment, not test internals)
- Diana is Cowork not Code (reasons, does not fix)
- Odie switched from Cowork to Code due to machine constraints today

---

## 5. Retrospective — 04-02

Full retrospective in: 04-02/retrospective_04_02.md

### Key findings

- Julian drifted depth-first by end of day — violated the Level 1 discipline we established in the morning
- Team composition was invented not researched — not SDD-TDD compatible
- No culture document exists — Dashan's preferences not captured anywhere
- Cold start preparation not scalable — Julian writing context is a band-aid
- Julian did not call the retrospective — Dashan had to
- Sequential composition limits value of role isolation

### Commitments for next session

- Julian calls retrospective every 4 hours and at end of day
- Julian produces research.md before opening Peter
- Julian asks three upfront questions before any document: machines/usernames, repo/file model, domain context level
- culture.md created today, lives in Verification-Cloud repo root
- Next cohort design must be researched against SDD-TDD practice

---

## 6. Deferred

- Four remaining issues in plan.md (Steps 4-6, Igor scope, Diana pull condition, Odie in plan)
- Actual execution of ex100_fifo pipeline
- SDD-TDD compatible team composition research
- Notification mechanism research (Telegram, Claude dispatch)
- Hello-world warmup run before next real task
- Concurrent role design

---

## 7. Unresolved

- Where exactly does culture.md live — Verification-Cloud root or observe_dashan root?
- Who is responsible for updating culture.md during a session?
- What is the right warmup protocol before a real task?
- How do we design for concurrency in next cohort iteration?
