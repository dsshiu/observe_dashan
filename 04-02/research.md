# research_04_02.md — Julian's Research Findings

## Date: 04-02 | Authorized by Dashan

These are findings from researching things Julian invented during 04-02 that should have been researched first. Organized by topic. References follow each section.

---

## 1. SDD-TDD compatible team composition

**What established practice says:**

SDD defines clear role boundaries: a product/spec owner defines behavior and is the ground truth for all downstream teams, implementers use the spec as a contract, testers validate against the same spec, and architects verify specs fit technical constraints. These roles are distinct and the spec is the handoff artifact between them — not verbal briefing, not code.

The correct team composition for a software project following SDD+TDD is therefore organized around the spec, not around the technology layers. For Verification-Cloud this likely means: one role owning spec integrity per major component (presim, CloudSim), domain-specific implementer+tester roles per component, and a separate end-to-end integration role. Julian invented a generic software team (planner, coder, tester, diagnostician, integrator) which maps poorly to this model.

**Implication:** Next cohort design should start from the component map of Verification-Cloud, assign one spec-owner and one implementer per component, and one integrator across all components. Research the component boundaries first, then assign roles.

**On frameworks:** The dominant multi-agent software development frameworks as of early 2026 with real production adoption are CrewAI (role-based, most widely adopted for structured workflows), LangGraph (graph-based, best for complex stateful pipelines with conditional logic), and Microsoft AutoGen v0.4 (event-driven, enterprise-focused, rebuilt from scratch in January 2025). LangChain-era frameworks (including early ChatDev) are largely superseded. CrewAI's role-based model — where each agent has a defined role, goal, and backstory — is the closest analogue to what Julian designed, but with significantly more production-grade tooling for observability and lifecycle management.

**References:**

- testRigor: "How Does Specification-Driven Development Work?" https://testrigor.com/blog/how-specification-driven-development-works/
- DataCamp: "CrewAI vs LangGraph vs AutoGen" https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen
- spaceo.ai: "Agentic AI Frameworks: Complete Enterprise Guide for 2026" https://www.spaceo.ai/blog/agentic-ai-frameworks/
- CrewAI Agent Operations Platform launch, late 2025: https://o-mega.ai/articles/langgraph-vs-crewai-vs-autogen-top-10-agent-frameworks-2026

---

## 2. Agent coordination protocols

**What established practice says:**

The shared message bus pattern is the coordination mechanism that survives production. Agents publish to a shared channel; messages persist until acknowledged; agents don't need to know each other's APIs or whether peers are online. This is essentially what queue.md is — Julian invented something with a known name and a known failure mode profile.

The dominant coordination patterns in 2026 are: sequential pipeline (each agent processes output of previous — what today's cohort does), parallel/concurrent (independent tasks assigned simultaneously — what today's cohort does not do), hierarchical (orchestrator delegates to workers — Peter→others), and handoff (agent passes task to specialist mid-stream). The right choice depends on task structure and dependency graph, not on preference.

Microsoft's pattern guide recommends starting centralized (one orchestrator) and decentralizing only when concrete scalability bottlenecks appear. Peter as central coordinator is the right starting point.

A significant finding: "offline isn't binary — an agent can respond to heartbeats but be stuck in an error loop." Odie's role watching for `flagging` or `blocked` status is the right pattern, but a stuck agent burning cycles without progress is harder to detect than one that has explicitly flagged itself.

**References:**

- tacnode.io: "Agent Coordination: How Multi-Agent AI Systems Work Together" https://tacnode.io/post/multi-agent-coordination
- DEV Community: "Multi-Agent AI: 5 Coordination Patterns I Learned the Hard Way" https://dev.to/triqual/multi-agent-ai-5-coordination-patterns-i-learned-the-hard-way-kbk
- Microsoft Azure Architecture: "AI Agent Orchestration Patterns" https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns
- AWS: "Multi-Agent collaboration patterns with Strands Agents" https://aws.amazon.com/blogs/machine-learning/multi-agent-collaboration-patterns-with-strands-agents-and-amazon-nova/

---

## 3. Agent cold-start and memory

**What established practice says:**

The diary mechanism (agents read prior self-logs at cold start) maps to episodic memory in agent architectures — a recognized pattern. No superior alternative surfaced. The main finding is the recommendation to start with two agents for at least a week before scaling the cohort. Julian proposed a seven-agent cohort from day one for a first experiment. The research suggests this was premature.

**References:**

- vibecoding.app: "Multi-Agent Software Development: Complete Guide" https://vibecoding.app/blog/multi-agent-software-development-workflow

---

## 4. Delegation and supervised autonomy

**What established practice says:**

Shadow mode → notify mode → autonomous, graduated by accuracy over N decisions, is directionally consistent with human-in-the-loop (HITL) ML literature. No single canonical framework exists — this remains an active research area. The graduation criteria (accuracy threshold, recency weighting, de-graduation on context shift) are the parts most in need of precise specification before implementation.

---

## 5. Retrospective formats and cadence

**What established practice says:**

Agile retrospectives run at sprint end (1-2 weeks). Blameless postmortems run after incidents. The 4-hour intra-session cadence is more aggressive than standard practice — the closest analogue is lean manufacturing's kaizen (continuous improvement loops). The principle is sound; the cadence is appropriate for an experimental period and should be revisited as the cohort matures.

---

## 6 & 7. Pull-based pipeline handoffs and checkpoint conventions

**What established practice says:**

Git worktrees (each agent with its own working copy) is the established pattern for parallel agent work on the same codebase, preventing merge conflicts. The manual clone-per-agent approach used today is equivalent but without the automation. The `[DASHAN]` approval gate maps to the "approval gate" pattern in CI/CD — a standard checkpoint before promotion to the next stage.

**References:**

- vibecoding.app: "Multi-Agent Software Development" https://vibecoding.app/blog/multi-agent-software-development-workflow
- Perforce: "Parallel Development at Scale" https://www.perforce.com/blog/vcs/parallel-development

---

## 8 & 9. Parallelism, pipelining, and Peter's planning capability

**What established practice says:**

**Critical Path Method (CPM):** The established tool for identifying which tasks are sequential (on the critical path) and which can run in parallel (float). A plan without CPM analysis is a guess. Peter's current souls.md gives him no instruction to identify the critical path before sequencing tasks.

Two techniques for shortening the critical path: fast-tracking (running parallel tasks that were planned sequentially) and crashing (adding resources to critical path activities). Peter should know both.

**Pipelining in software development:** One worker finishes a feature and moves to the next; another worker enables barely-finished features in the integration layer; another handles CI/CD of older features. This is stage-overlap, not task parallelism. It maximizes throughput by keeping all workers active at their respective maturity levels simultaneously.

**Implication for Peter's souls.md:** Add a mandatory planning step: before sequencing tasks, Peter must identify (1) the critical path, (2) which tasks have float and can run in parallel, (3) which tasks can be pipelined with later tasks. A Peter who doesn't do this is leaving throughput on the table.

**References:**

- Wikipedia: "Critical Path Method" https://en.wikipedia.org/wiki/Critical_path_method
- Wrike: "The Critical Path Method in Project Management: 2026 guide" https://www.wrike.com/blog/critical-path-is-easy-as-123/
- Perforce: "Parallel Development at Scale" https://www.perforce.com/blog/vcs/parallel-development

---

## 10. Constitution.md — the established convention

**What established practice says:**

GitHub Spec Kit introduces `constitution.md` as the standard vessel for non-negotiable project principles: architectural conventions, testing approaches, opinionated technology stacks, coding standards. It is read by AI agents before any work begins and governs all generated code and plans. This is the established name and format for what `culture.md` and `technical-tendencies.md` were trying to be.

The two documents have been retired and consolidated into `constitution.md` in the `observe_dashan` repo root.

**References:**

- Microsoft Developer Blog: "Diving Into Spec-Driven Development With GitHub Spec Kit" https://developer.microsoft.com/blog/spec-driven-development-spec-kit
- GitHub Spec Kit: https://github.com/github/spec-kit
