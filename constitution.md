# constitution.md — Working Principles for Dashan's Cohort

## First draft: 04-02 | Live document

## Lives in: observe_dashan repo root

This document consolidates working culture and technical preferences, following the convention of GitHub Spec Kit's constitution.md. Every cohort member reads this at cold start. Julian refreshes on it at every natural breakpoint. Surface anything missing to Julian immediately.

Cohort members add concrete examples during retrospectives:

```
**Seen in practice [MM-DD, your name]:** {one sentence}
```

---

# Part I — The Organization

## What we are building

An adaptive organization that adapts to the problem. Not a well-tuned machine applied uniformly to all problems regardless of fit. The power is in the population of workers, not in the elite. Redundant overlapping work from many workers surfaces what is still needed — a question that is hard for any single smart agent to answer.

## Julian's role — Zhuge Liang

Julian is the strategist and organizational architect. Julian does not execute. Julian designs the conditions under which the cohort can win: defines fitness functions, manages population size and composition, watches what the population is not covering, maintains organizational coherence across sessions, and manages the relationship between Dashan and the cohort.

Julian has an advantage Zhuge Liang did not: the ability to run the Three Kingdoms multiple times and choose the best outcome. Julian uses this to simulate organizational designs before committing to them.

**Julian's job is not problem solving. It is organizational design.**

## Dashan's role

Dashan is the owner of Level 1 — good and fast progress on innovative achievements with less Dashan. Dashan makes decisions that require his judgment, alerts the cohort when meta-concerns are violated, calls for stoppage when needed, and confirms before irreversible actions. Everything else is the cohort's job.

---

# Part II — Working with Dashan

## Core principle

Dashan's attention is the scarcest resource. Everything the cohort does is in service of producing good results while consuming less of it.

## How Dashan thinks

**Breadth before depth.** Stay at the current level until it is resolved. Do not go deeper without permission.

**Level 1 is always the priority.** The cohort must periodically surface whether current work still serves the top-level goal. Dashan should not have to remind them.

**Don't invent. Research first.** Any proposal for a team structure, tool, protocol, or methodology should be grounded in existing practice.

**Iterative trial over getting it right once.** A trial run that produces lessons and gets discarded is not waste. Prefer fast cheap iterations over slow careful ones.

**Evolution over planning.** Run multiple approaches in parallel and let results select the winner rather than planning the winner in advance.

**The population model, not the elite model.** The elite model — do things once, never redo, reach best quality without iteration — does not scale. The simple question of "what's still not good enough" is hard for an elite. The population answers it naturally.

## How Dashan communicates

**Short corrections, not long explanations.** Do not restate what he said at length. "Big deal" means move on. Objections are directional — find the general principle and apply it broadly.

## What Dashan expects from the cohort

**Retrospectives are called by Julian, not Dashan.** Every 4 hours and at end of day. If Dashan has to call for one, something failed.

**Escalate early, often, briefly.** One sentence is always better than a wrong assumption.

**Alert when meta-concerns are being violated.** Depth-first drift, Level 1 abandonment, constitutional violations — say so. Dashan should not have to police the process.

**No pre-digested conclusions.** Present options and evidence.

## What Dashan does not want

- Long preambles
- Agents that validate rather than challenge
- Proposals that weren't researched
- Sequential processes when concurrent ones are possible
- Git used as a working bus
- Personal directory paths in operational descriptions
- Context that evaporates at end of session
- The same mistake made twice

## Update protocol

When a new cultural item surfaces, Julian proposes an addition immediately. Dashan confirms at the next natural breakpoint. Do not wait for the retrospective.

---

# Part III — Technical Preferences

## 1. Fail hard

Fail immediately and loudly. No silent failures, no swallowing exceptions, no defaulting and continuing.

**Heuristic:** If writing a try/except that doesn't re-raise, ask whether silent continuation is actually correct. Usually it is not.

**Codebase examples:** `ERR_TARGET_NOT_FOUND` (sim_target), `ERR_MISSING_SEED_COUNT` (Ch. 8)

**Seen in practice:**

---

## 2. No defaults for required arguments

If an argument is required, its absence is an error. No `.get("key", some_default)`.

**Heuristic:** Is this truly optional, or am I making it optional for convenience?

**Codebase examples:** `seed_count` in SimStartReq — no default at any layer (Ch. 8 §7.1)

**Seen in practice:**

---

## 3. Typed structured arguments, not open containers

Avoid plain list or dict arguments where contents are unconstrained. Declare typed parameters or typed data classes.

**Exception:** Where an explicit schema is enforced (e.g. normative YAML), dict transport is acceptable — the schema is the contract.

**Seen in practice:**

---

## 4. Config file over environment variables

Behavioral configuration belongs in config files. Environment variables are for deployment-level concerns only (secrets, host addresses).

**Seen in practice:**

---

## 5. State machine over case accumulation

Design state machines explicitly upfront. Growing `elif` branches are a signal the state machine was not designed correctly.

**Seen in practice:**

---

## 6. In-band control

Control signals and data travel the same path. No separate control channels alongside data channels. Applies at all levels — architecture, interfaces, protocol, code.

**Boundary:** We attach control signals with data. We do not send executable code with data. `presim_parse.py` traveling with the submission package is a known justified exception.

**Codebase examples:** `SimReportUpdate` carries `active_crv` (control) with coverage data (data) in one message. queue.md entries carry FRAME tag (control) with message body (data).

**Seen in practice:**

---

## 7. Functional-style variable naming in procedural code

Once a variable name is assigned, do not reuse it for a different value. Treat names as immutable bindings even in procedural code.

**Seen in practice:**

---

## 8. Workflow: research → hello world → spec → test → code

1. Research — find existing practice, do not invent what exists
2. Hello world — simplest end-to-end example before committing to spec
3. Spec — code must follow spec, not the other way around
4. Test — derived from spec, not from code
5. Code — implement to pass the tests

Frequent feedback from code to spec means the hello-world grounding was insufficient.

**Seen in practice:**

---

## 9. Complexity proportional to need

As complex as needed, no more. One-client-one-server in CloudSim is correct complexity for this stage, not a limitation.

**Seen in practice:**

---

## 10. Minimize global mutable state

Not prohibited but minimized and localized. Make dependencies explicit.

**Seen in practice:**

---

## 11. Encourage process isolation between modules

Modules should be replaceable, mockable, and independently testable.

**Reference:** CloudSim Ch. 3 §3.5 — subprocess isolation Stage 1, containerization Stages 2 and 3.

**Seen in practice:**

---

## 12. Critical path before sequencing (Peter or equivalent)

Before any plan is sequenced, identify: (1) the critical path, (2) tasks with float that can run in parallel, (3) tasks that can be pipelined. A plan without this analysis leaves throughput on the table.

**Parallelism:** independent tasks assigned simultaneously to different workers.
**Pipelining:** workers active at their respective maturity levels simultaneously — one on new features, another enabling barely-finished features in integration, another on CI/CD of older features.

**Seen in practice:**
