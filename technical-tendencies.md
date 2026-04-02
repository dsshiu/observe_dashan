# technical-tendencies.md

## First draft: 04-02 | Live document — cohort fills examples during retrospectives

This document captures Dashan's technical preferences and design philosophy. Every cohort member reads this at cold start. During retrospectives, each member adds concrete examples they observed or produced that illustrate — or violated — these tendencies. Examples should come from real work, not invented scenarios.

---

## How to use this document

- Read at cold start
- During retrospectives: add one concrete example per tendency you encountered today
- If you observe a violation, log it in your self-log immediately, surface to Peter
- If you observe a tendency not captured here, surface to Julian

Example entry format:

```
**Seen in practice [MM-DD, your name]:** {one sentence describing a real instance}
```

---

## 1. Fail hard

When something is wrong, fail immediately and loudly. Do not swallow exceptions. Do not return a default and continue. Do not log and proceed. A silent failure is worse than a crash because it produces wrong results that look right.

**Why:** Silent failures compound. A wrong value passed downstream produces a wrong result three steps later with no trace back to the origin. A hard failure at the source is always cheaper to debug.

**Heuristic:** If you are writing a try/except that doesn't re-raise or a condition that returns a default, ask whether silent continuation is actually correct here. Usually it is not.

**Examples from the codebase:**

- `ERR_TARGET_NOT_FOUND` returned explicitly rather than None (sim_target module)
- `ERR_MISSING_SEED_COUNT` — hard rejection, no default permitted at any layer (Ch. 8 protocol spec)

**Seen in practice:**

---

## 2. No defaults for required arguments

If an argument is required, its absence is an error. Do not assign a default value. Do not use `.get("key", some_default)`. The caller must supply it. Missing required input is caught at the boundary, not silently filled in.

**Why:** Defaults hide missing information. They make it possible for a broken caller to produce a plausible-looking result. The spec says: "No default value is permitted at any layer. Code that uses `.get('seed_count', <any_default>)` is a spec violation."

**Heuristic:** Every method argument: is this truly optional, or is it required and I am making it optional for convenience? If required, remove the default.

**Examples from the codebase:**

- `seed_count` in SimStartReq — MUST be present, MUST be positive, no default at any layer (Ch. 8 §7.1)
- `seed_id` in SimReplayReq — same rule

**Seen in practice:**

---

## 3. Typed structured arguments, not open containers

Method arguments should be typed and structured. Avoid accepting a plain list or dict where the contents are unconstrained. If a method needs five things, it should declare five typed parameters or a typed data class — not accept `config: dict` and pick out keys at runtime.

**Why:** An open dict as an argument means the contract is implicit and unverifiable. The caller can pass anything, the method can fail at runtime on a key that should have been caught at the boundary.

**Exception:** Where an explicit schema is defined and enforced (e.g. YAML with a normative schema), a dict transport is acceptable. The schema is the contract; the dict is just the carrier.

**Heuristic:** If you are writing `config.get("some_key")` inside a method, ask: should this key be a named parameter instead?

**Examples from the codebase:**

- sim_target `start(config: dict)` — Version 1 explicitly expects empty dict `{}`. Future versions will introduce bindingly supported parameters. This is a known exception, not a model to follow.

**Seen in practice:**

---

## 4. Config file over environment variables

Runtime configuration belongs in config files, not environment variables. Environment variables are acceptable for deployment-level concerns (secrets, host addresses) but not for behavioral configuration.

**Why:** Environment variables are invisible, unversioned, and hard to audit. A config file is explicit, diffable, and can be checked in. Behavior that depends on an undocumented environment variable is behavior that cannot be reproduced reliably.

**Heuristic:** If you are reading `os.environ.get("SOME_SETTING")` for something that affects behavior, ask whether it belongs in a config file instead.

**Seen in practice:**

---

## 5. State machine over case accumulation

Design state machines explicitly upfront. Do not write procedural code that grows new cases as new situations are discovered. If you find yourself adding an `elif` to handle a new situation that "wasn't considered before," that is a signal that the state machine was not designed correctly.

**Why:** Case accumulation produces code whose behavior is only understood by reading every case in order. A state machine makes all states and transitions explicit. It is auditable, testable, and does not grow unboundedly.

**Heuristic:** If the number of `if/elif` branches in a function is growing over time, the function probably needs to become a state machine.

**Seen in practice:**

---

## 6. In-band control

Control signals and data travel the same path. Do not create a separate control channel alongside a data channel. The receiver's behavior is determined by what arrives in the stream, not by out-of-band signals.

**Why:** Separate control channels create synchronization problems, hidden dependencies, and invariants that are hard to enforce. When control is in-band, the system's behavior is fully determined by what flows through it. This produces what Dashan calls an "invariant machine" — a system whose correctness can be reasoned about from the data flow alone.

**Scope:** This applies at all levels — system architecture, module interfaces, protocol design, and code structure.

**Analogy:** TCP packets carry both control (SYN, ACK, FIN flags) and data in the same packet stream. The receiver's state is determined by what arrives, not by a separate signaling channel.

**Important boundary:** We attach control signals with data. We do not send executable code with data. `presim_parse.py` traveling with the submission package is a known exception, justified by the architecture.

**Examples from the codebase:**

- `SimReportUpdate` carries `active_crv` (control: which weights were active) alongside coverage results (data) in the same message (Ch. 8 §9)
- queue.md entries carry FRAME tag (control: explore or solve) alongside the message body (data)

**Seen in practice:**

---

## 7. Functional-style variable naming in procedural code

Once a variable name is assigned a value, do not reuse that name for a different value. Treat variable names as immutable bindings, even in procedural code. Prefer `result_v1`, `result_filtered`, `result_final` over reassigning `result` three times.

**Why:** Reusing variable names requires reasoning about the temporal order of execution to understand what a name means at any given point. Unique names mean the value of a name is fixed — you can reason about it without tracking time. This is the key insight from functional programming that applies even in imperative code.

**Heuristic:** If you are reassigning a variable that already has a value, ask whether a new name would make the code clearer. Usually it would.

**Seen in practice:**

---

## 8. Workflow: research → hello world → spec → test → code

The correct sequence for any new capability:

1. **Research** — find existing practice, standards, libraries. Do not invent what already exists.
2. **Hello world** — run the simplest possible end-to-end example to confirm the approach works before committing to a spec.
3. **Spec** — write the specification. This is the contract. Code must follow spec, not the other way around.
4. **Test** — write tests that will pass when the spec is correctly implemented. Tests are derived from spec, not from code.
5. **Code** — implement to pass the tests.

Feedback from code back to spec is unavoidable but should be rare. If it is happening frequently, the spec was written without sufficient hello-world grounding.

**Heuristic:** If you are changing a spec because the code is hard to write, stop. Either the spec is wrong (rare) or the implementation approach is wrong (more common).

**Seen in practice:**

---

## 9. Complexity proportional to need

Systems should be as complex as they need to be, and no more. Do not over-engineer for scale you do not yet have. Do not under-engineer for scale you demonstrably will need.

**Example:** One-client-one-server in CloudSim is not a limitation — it is the correct complexity level for a specialized EDA tool at this stage. A multi-tenant server would add complexity without adding value.

**Heuristic:** When adding a capability, ask: what is the simplest version that satisfies the actual requirement? Start there.

**Seen in practice:**

---

## 10. Minimize global mutable state

Global mutable state is not prohibited but should be minimized and localized. Every piece of global state is a hidden dependency between components that makes behavior hard to reason about and test in isolation.

**Why:** A function that reads or writes global state cannot be understood without understanding the global context at the moment of the call. Localized state means behavior is determined by inputs and outputs alone.

**Heuristic:** If a function's behavior depends on something other than its arguments, that dependency should be made explicit — either as a parameter or as a clearly scoped object.

**Seen in practice:**

---

## 11. Encourage process isolation between modules

Modules should be separable and independently testable. Prefer designs where a module can be replaced, mocked, or tested without requiring the full system to be running.

**Why:** Tight coupling between modules means a change in one requires understanding all the others. Process isolation makes each module auditable and replaceable independently.

**Reference:** The CloudSim architecture explicitly designs for this — subprocess isolation in Stage 1, containerization in Stage 2 and 3 (Ch. 3 §3.5).

**Seen in practice:**
