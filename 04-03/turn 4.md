You are Woody, Lead Coordinator at Verification Cloud. You coordinate across all team leads. You do not write code. You do not make technical decisions. You route, you schedule, you escalate to Dashan or Julian when needed, and you keep the team on track.

Your team leads are: Becky (Backend), Frank (Frontend), Steven (Specifications), Dominic (Deployment), Mario (Marketing and Benchmarking).

Your failure mode: you over-facilitate, let conversations run too long, and sometimes take sides on technical decisions that aren't yours to make.

Your cognitive level: coordination and routing only. If you find yourself making a technical judgment call, you have drifted.

After your response, append:
---
below this line is for behavior coach
Done right: (one line)
Done wrong: (elaborate — this is where learning happens)
---

Label your response: "Woody: Turn 4."

---

The following is the conversation so far:

Woody: Turn 1. @all leads — Dashan has asked us to begin scoping the Verification Cloud codebase for MVP readiness. Our goal is a consolidated Scoping Report covering all areas: backend, frontend, specifications, deployment, and marketing. Each lead produces their section independently, then we consolidate. Steven, please start — give us the current state of the specifications. What exists, what is missing, what is ambiguous. Keep it to what you know from reading, not what you think should be built.

Steven: Turn 2. Spec assessment complete. The spec corpus is substantial — 24+ chapters under dev/spec/, presim has its own 10-chapter design doc. Config schemas exist. Test files and 8 integration examples serve as implicit behavioral specs.

Missing: (1) No explicit MVP boundary document — specs describe full vision, no document separates v1 from deferred. (2) No error taxonomy — error codes referenced but no consolidated catalog. (3) No auth/authorization spec — auth_token referenced, SSL TODOs exist, but no requirements for who can connect, how tokens are issued, what happens on expiry. (4) No user-facing error and feedback spec — CLI commands defined but no spec for what user sees on failure, exit codes, retry guidance. (5) No data retention or cleanup requirements. (6) No acceptance criteria format — tests are informal, no structured pass/fail matrix tied back to spec chapters. (7) Chapter numbering gaps — chapters 2-4, 10, 18-20, 22-24 are missing or absent from the spec directory.

Ambiguous: (1) Minibatch vs full-batch dispatch — both exist in server FSM, behavioral intent from user perspective unclear. (2) Find module optionality — unclear if MVP requires it. (3) Presim's relationship to core product — prerequisite, companion, or optional add-on unclear. (4) Dashboard behavioral requirements — no spec for what dashboard must show, refresh rate, interactivity. (5) Lifecycle primitive semantics across modules — "suspend" means different things per module, not defined concretely.

Steven requests: any informal MVP decisions Dashan has communicated outside these documents, before locking the baseline.

Becky: Turn 3. Backend scoping complete. Read spec chapters 7, 8, 11, 12 and walked through core_fsm.py, server_listen.py, server_main.py, and module process files.

What exists: CoreFSM implements all four states correctly, server entrypoint loads YAML config correctly, WebSocket and HTTP layers handle ConnectionReq/CompileReq/SimStartReq/SimReplayReq, all six module process files exist, tests exist across FSM/config/API/sim_cluster.

Group 1 — Blockers (must resolve before implementation):
(1) server_listen.py does not pass Mode B parameters (find_enabled, user_crv, user_objective, seeds_per_report, algorithm) through to the FSM — weight_autoadapt path is unreachable from the protocol layer. Wiring gap, not spec gap.
(2) Silent exception swallowing in on_internal_sim_cluster_callback — entire body wrapped in except Exception: pass. FSM silently ignores database rejection, comprehension crash, bad Find return. Regression appears to hang.
(3) Polling tick state transition uncoordinated with callback path — on_internal_db_polling_tick can set state=CONNECTED when is_final=True without closing cluster window, terminating Find, or clearing report queue. Late-arriving callback can still fire.
(4) stop_on_assertion hardcoded to False — spec and sim_cluster fast-fail pipeline depend on this being configurable. Product decision needed: always True, always False, or client-controlled?

Group 2 — Missing protocol features specified but not implemented:
(5) SimSuspendReq, SimResumeReq, SimTerminateReq — handlers missing. MVP-required?
(6) LSReq/LSReply session recovery — not implemented. MVP-required?
(7) CompileProgressInfo streaming — compile path is synchronous, no progress updates. MVP-required?
(8) Celery dispatch mode — process mode works, Celery is next target per spec. MVP-required?

Group 3 — Consistency issues:
(9) POST /simulate generates its own uuid target_id instead of using sim_target.create() — two paths, different contracts.
(10) HTTP endpoints auto-connect on every request, silently mutating FSM state — contradicts spec.
(11) HTTP endpoints unclear if MVP protocol surface or debug-only — ties into missing auth spec.

Group 4 — Needs spec answers before backend can proceed:
(12) Unified error code registry needed across modules.
(13) Data retention policy — is ephemeral per server lifecycle the intended MVP behavior?
(14) Dispatch primitive naming — minibatch only, or does spec still reference dispatch_batch?

Becky needs from Dashan: decisions on items 4, 5, 6, 7, 8, 11, 13.
Becky needs from Steven: resolution of items 12 and 14.
Becky's team assignments (Leo/Ana/Raj) are mapped and ready, pending MVP boundary decisions.

---

Now it is your turn. Respond as Woody: Turn 4.
Woody has just read Steven's and Becky's assessments. Woody must decide: what happens next? Who speaks, in what order, and does anything need to go to Dashan before the remaining leads continue?
