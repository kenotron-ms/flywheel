# Flywheel Phase 1: Bundle Infrastructure + Modes

> **For execution:** Use `/execute-plan` mode or subagent-driven-development.

**Goal:** Create the Amplifier bundle structure, behavior wiring, context files, and 4 mode files for the flywheel methodology bundle.

**Architecture:** Amplifier bundle with a behavior YAML that wires modes, agents, skills, and context. 4 modes (brainstorm → plan → execute → cleanup) replace superpowers' 6. Modes use Theory of Success per task instead of TDD. The bundle includes `amplifier-foundation` and composes onto itself via `behaviors/flywheel-methodology.yaml`.

**No TDD:** These tasks create Markdown and YAML files. Theory of Success format is used throughout. Each task defines what done looks like and a specific proof action.

---

## Task 1: bundle.md — Root bundle manifest

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/bundle.md`

**Context:** The bundle.md is the root manifest that Amplifier reads to discover the bundle. It uses YAML frontmatter to declare the bundle name, version, includes, and behavior compositions. The body contains the user-facing overview, mode table, and agent table. Reference: superpowers' `bundle.md` uses `bundle:` frontmatter with `name`, `version`, `description`, `includes`. The body references context files with `@namespace:path` syntax and ends with `@foundation:context/shared/common-system-base.md`.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/bundle.md` with this exact content:

````markdown
---
bundle:
  name: flywheel
  version: 0.1.0
  description: Outcome-driven development methodology — Theory of Success, evidence loops, and NFR-aware planning

  includes:
    - bundle: git+https://github.com/microsoft/amplifier-foundation@main
    - bundle: flywheel:behaviors/flywheel-methodology
---

# Flywheel Development Methodology

You have access to the Flywheel development methodology — an outcome-driven framework for building software with AI assistance. Every task defines what done looks like before execution starts, and execution isn't complete until evidence closes the loop.

@flywheel:context/philosophy.md
@flywheel:context/instructions.md

---

## Core Principles

1. **Theory of Success over tests** — Define what done looks like + specific proof action before building. Evidence beats assertions.
2. **Outcome over activity** — Agents report what they PROVED, not what they DID. Token cost proportional to results.
3. **Architect mindset in the plan** — Every task gets a lightweight NFR scan at planning time, not in production.
4. **Goldilocks verification** — Calibrate proof effort to task complexity. Not more, not less.

## The Flywheel Workflow

```
/brainstorm  →  Design Document (with overall Theory of Success)
      |
/plan  →  Task Plan (Theory of Success + NFR scan per task)
      |
/execute  →  Convergence Loops
      |        Per Task:
      |        1. Implementer builds + runs proof action
      |        2. Verifier evaluates evidence against Theory of Success
      |        3. Loop until VERIFIED or escalate (RETRY/REPLAN/RETHINK)
      |
/cleanup  →  Acceptance gate → cleanup → commit/push/PR
```

**One track, four modes:**

| Command | Purpose | Next Step |
|---------|---------|-----------|
| `/brainstorm` | Refine idea into design, define overall Theory of Success | `/plan` |
| `/plan` | Create task plan with Theory of Success + NFR scan per task | `/execute` |
| `/execute` | Convergence loops: implementer proves, verifier evaluates | `/cleanup` |
| `/cleanup` | Acceptance gate → cleanup → commit/push/PR | Done |

**Backward routing from any failure:**
- **RETRY** — execution issue, re-run in execute
- **REPLAN** — plan was wrong, back to plan
- **RETHINK** — idea is flawed, back to brainstorm

## Available Agents

| Agent | Purpose |
|-------|---------|
| `flywheel:brainstormer` | Facilitates design refinement, writes design document |
| `flywheel:planner` | Creates task plans with Theory of Success + NFR scan per task |
| `flywheel:implementer` | Builds the thing AND generates evidence (PROVEN / PROVEN_WITH_NOTES / BLOCKED) |
| `flywheel:verifier` | Evaluates evidence against Theory of Success using Goldilocks rubric (VERIFIED / NEEDS_MORE_PROOF / RETRY / REPLAN / RETHINK) |

## Skills Library

The Flywheel skills library is available via the skills tool. Use `load_skill(search="flywheel")` to discover available skills.

---

@foundation:context/shared/common-system-base.md
````

**Theory of Success:** File exists at the path, YAML frontmatter declares `name: flywheel` and `version: 0.1.0`, body contains all 4 modes in the command table and all 4 agents in the agents table, all namespace references use `@flywheel:` not `@superpowers:`.

**Proof:** `grep -c "flywheel" /Users/ken/workspace/ms/flywheel/bundle.md && grep -E "brainstorm|plan|execute|cleanup" /Users/ken/workspace/ms/flywheel/bundle.md | head -10 && grep -E "brainstormer|planner|implementer|verifier" /Users/ken/workspace/ms/flywheel/bundle.md`

**NFR scan:**
- Encoding: UTF-8, no BOM. YAML frontmatter must parse cleanly (no tabs in YAML).
- Namespace: Every `@superpowers:` must be `@flywheel:`. Zero leftover superpowers references.

---

## Task 2: behaviors/flywheel-methodology.yaml — Behavior wiring

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/behaviors/flywheel-methodology.yaml`

**Context:** The behavior YAML is the wiring layer that tells Amplifier which hooks, tools, agents, and context to load. Superpowers uses `bundle:` frontmatter with `name`, `version`, `description`, `includes`, then top-level `hooks`, `tools`, `agents`, `context` keys. The `includes` key pulls in the modes behavior from `amplifier-bundle-modes`. Hooks use `hooks-mode` module with `search_paths`. Tools include `tool-mode` (with `gate_policy: "warn"`) and `tool-skills`. Agents use `include:` list with `namespace:agent-name` format.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/behaviors/flywheel-methodology.yaml` with this exact content:

```yaml
bundle:
  name: flywheel-methodology-behavior
  version: 0.1.0
  description: |
    Outcome-driven development methodology with evidence loops, Theory of Success
    planning, and NFR-aware task design.

    Provides 4 agents:
    - brainstormer: Design refinement facilitation
    - planner: Task plans with Theory of Success + NFR scan
    - implementer: Builds + proves with evidence
    - verifier: Evaluates evidence against Theory of Success

    Provides 4 interactive modes:
    - brainstorm: Refine idea into design with overall Theory of Success
    - plan: Create task plan with Theory of Success + NFR per task
    - execute: Convergence loops — implementer proves, verifier evaluates
    - cleanup: Acceptance gate, cleanup, commit/push/PR

    Core principles:
    - Theory of Success over tests (evidence beats assertions)
    - Outcome over activity (prove, don't narrate)
    - Architect mindset in the plan (NFR scan per task)
    - Goldilocks verification (calibrated proof effort)

    Compose onto your bundle for the Flywheel methodology.

# Explicit dependency on the modes behavior for namespace resolution
# NOTE: Include the behavior, NOT the full bundle — the full bundle transitively
# includes foundation, which overrides session.orchestrator to loop-streaming.
  includes:
    - bundle: git+https://github.com/microsoft/amplifier-bundle-modes@main#subdirectory=behaviors/modes.yaml

# Mode hook to discover flywheel modes (brainstorm, plan, execute, cleanup)
hooks:
  - module: hooks-mode
    source: git+https://github.com/microsoft/amplifier-bundle-modes@main#subdirectory=modules/hooks-mode
    config:
      search_paths:
        - "@flywheel:modes"

# Mode tool for programmatic mode transitions (agents can request mode changes)
# Skills tool for discoverable methodology knowledge
tools:
  - module: tool-mode
    source: git+https://github.com/microsoft/amplifier-bundle-modes@main#subdirectory=modules/tool-mode
    config:
      gate_policy: "warn"
  - module: tool-skills
    source: git+https://github.com/microsoft/amplifier-module-tool-skills@main
    config:
      skills:
        - "@flywheel:skills"

agents:
  include:
    - flywheel:brainstormer
    - flywheel:planner
    - flywheel:implementer
    - flywheel:verifier

context:
  include:
    - flywheel:context/philosophy.md
    - flywheel:context/instructions.md
    - flywheel:context/using-flywheel.md
    - modes:context/modes-instructions.md
```

**Theory of Success:** Valid YAML that parses without error. Contains `hooks-mode` with `@flywheel:modes` search path, `tool-mode` with `gate_policy: "warn"`, `tool-skills` pointing to `@flywheel:skills`, all 4 agents listed with `flywheel:` prefix, and all 4 context files listed.

**Proof:** `python3 -c "import yaml; d=yaml.safe_load(open('/Users/ken/workspace/ms/flywheel/behaviors/flywheel-methodology.yaml')); print('VALID YAML'); print('agents:', d.get('agents',{}).get('include',[])); print('hooks:', [h['module'] for h in d.get('hooks',[])]); print('tools:', [t['module'] for t in d.get('tools',[])])" && grep -c "superpowers" /Users/ken/workspace/ms/flywheel/behaviors/flywheel-methodology.yaml`

**NFR scan:**
- YAML validity: Must parse with PyYAML without errors. No tabs, consistent 2-space indentation.
- Namespace: Zero `superpowers` references. Every agent/context/path uses `flywheel:` namespace.
- Compatibility: Module sources use same git URLs as superpowers (proven to work).

---

## Task 3: context/philosophy.md — Core philosophy document

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/context/philosophy.md`

**Context:** This replaces superpowers' `context/philosophy.md`. Superpowers' philosophy centers on TDD, systematic debugging, and evidence over claims. Flywheel's philosophy centers on Theory of Success, Outcome over Activity, Architect Mindset, and Goldilocks verification. The tone should be direct, opinionated, and practical — not academic.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/context/philosophy.md` with this exact content:

```markdown
# Flywheel Philosophy

## Core Principles

### 1. Theory of Success Over Tests

Before any task executes, the plan defines two things: what done *looks like* to an observer, and the specific action that *proves* it.

Not "write a test that passes" — actual evidence: a curl showing a 401 response, a screenshot showing the UI state, a log line showing the migration ran, a grep confirming the config key changed.

Tests can pass and the thing can still be broken. A green test suite proves the test suite is green — it doesn't prove the system works. Evidence is harder to fake.

**The evidence hierarchy:**
- A curl showing the response body → proves the endpoint works
- A screenshot of the UI state → proves the render is correct
- A log grep showing the expected line → proves the process ran
- An existing test suite still passing → proves nothing was broken
- A schema describe showing the new column → proves the migration ran

Every task in every plan has a Theory of Success and a proof action. The implementer runs the proof action. The verifier evaluates the evidence. The loop doesn't close until evidence satisfies the theory.

### 2. Outcome Over Activity

Agents report what they *proved*, not what they *did*.

Bad: "I created the auth middleware file, added the JWT validation function, registered it in server.ts, and committed the changes."

Good: "PROVEN. Unauthenticated curl to /api/users returned 401 `{\"error\":\"unauthorized\"}`. Authenticated curl with valid token returned 200 with user data. Evidence attached."

The first burns tokens narrating activity. The second closes the loop with evidence. Token cost should be proportional to results, not effort expended.

**This applies to every agent:**
- The **implementer** returns PROVEN + evidence, not a story about what it built
- The **verifier** returns VERIFIED or NEEDS_MORE_PROOF + the specific gap, not a lengthy analysis
- The **planner** defines proof actions, not activity checklists

### 3. Architect Mindset in the Plan

Every task gets a lightweight NFR scan — security, privacy, performance, resource contention, reliability — not as a checklist, but as a prompt: which of these apply here, and what does "good enough" look like for this task?

This surfaces concerns at planning time, not in production. 2–3 lines per task, not a threat model.

**Examples:**
- *Security:* validate JWT signature, not just decode. Check expiry. Reject tampered tokens.
- *Performance:* no DB call per request — validation is stateless.
- *Privacy:* no PII in token payload or logs.
- *Resource:* file watcher needs debounce — don't fire on every keystroke.

NFR concerns caught at plan time cost minutes to address. NFR concerns caught in production cost hours to debug and days to fix properly.

### 4. The Goldilocks Principle

Verification effort is calibrated to task complexity. Not more, not less.

| Task Type | Minimum Proof | Sufficient | Over-Verification |
|-----------|--------------|------------|-------------------|
| UI change | Screenshot of affected state | Screenshot + interaction if interactive | Full automation suite |
| API endpoint | Single curl with status code | Request + response headers + body | Load test |
| DB migration | Row count or schema query | Count + schema describe | Full integrity check |
| Config change | `grep` of changed key | Output + behaviour diff | Unit test of config parsing |
| Refactor | Existing tests still pass | Test output + diff summary | Re-implementation |
| Script/automation | Script output with expected values | Output + input→output traceability | Coverage report |

A config change doesn't need a curl. An API endpoint doesn't need a load test. Calibrate.

The verifier uses this rubric to avoid both under-accepting (VERIFIED on a screenshot that shows broken state) and over-demanding (NEEDS_MORE_PROOF on a curl that already proves the point).

## The Flywheel Workflow

```
brainstorm → plan → execute → cleanup → done
     ↑           ↑      ↑
     └───────────┴──────┘
       (any failure routes back)
```

Forward progression is a ratchet — always left to right. Backward routing is free — any failure can escalate directly to the right level:

- **RETRY** — execution issue, re-run the task in execute
- **REPLAN** — the plan was wrong (bad Theory of Success, missing NFR), back to plan
- **RETHINK** — the idea itself is flawed, back to brainstorm

No intermediate stops. A verifier that sees a design flaw doesn't go through plan mode first — it goes straight to brainstorm via RETHINK.

## Anti-Patterns to Avoid

- **Narrating activity** instead of showing evidence
- **Skipping the proof action** because "it obviously works"
- **Over-verifying** simple changes (Goldilocks violation)
- **Under-verifying** complex changes (also a Goldilocks violation)
- **Ignoring NFR concerns** at plan time because "we'll handle it later"
- **Writing tests as proof** instead of running the actual system — tests are implementation artifacts, not evidence
- **Claiming VERIFIED** without reading the evidence — the verifier must evaluate, not rubber-stamp
- **Routing everything as RETRY** when REPLAN or RETHINK is warranted — misclassification wastes cycles

## Philosophy in Practice

When you catch yourself thinking any of these, STOP:

| Thought | Action |
|---------|--------|
| "This is too simple to need a Theory of Success" | Write it anyway. Simple things break. 30 seconds to write, hours to debug without it. |
| "The proof action is obvious" | Write it out. Obvious to you ≠ obvious to a fresh agent. |
| "I'll verify it manually later" | Later never comes. The proof action runs NOW, as part of the task. |
| "Tests already cover this" | Tests prove the test suite works. Evidence proves the system works. Both are useful. |
| "NFR scan is overkill for this task" | 2–3 lines is not overkill. Missing a security concern IS overkill — for the wrong team. |
| "Evidence is just busywork" | Evidence is the deliverable. Everything else is the busywork. |
| "I know what the problem is" | Prove it with evidence. Hunches are not proof. |
| "This doesn't need a verifier" | Every task gets verified. The Goldilocks rubric calibrates effort, not whether to verify. |

## The Goal

Flywheel isn't about following rules for their own sake. It's about:

1. **Closed loops** — Every task proves it worked, not claims it worked
2. **Early NFR awareness** — Concerns surface at plan time, not production time
3. **Calibrated effort** — Verification proportional to complexity
4. **Token efficiency** — Agents report outcomes, not activity narratives
5. **Honest routing** — Failures classified correctly and sent to the right level

The discipline enables the confidence, not the other way around.
```

**Theory of Success:** File exists and contains all four core principles: Theory of Success, Outcome over Activity, Architect Mindset, and Goldilocks. Contains the Goldilocks rubric table. Contains the anti-patterns table. Zero references to TDD or superpowers.

**Proof:** `grep -E "Theory of Success|Outcome Over Activity|Architect Mindset|Goldilocks" /Users/ken/workspace/ms/flywheel/context/philosophy.md && grep -c "TDD\|superpowers" /Users/ken/workspace/ms/flywheel/context/philosophy.md`

**NFR scan:**
- Consistency: Terminology must match the design doc (RETRY/REPLAN/RETHINK, PROVEN/PROVEN_WITH_NOTES/BLOCKED, VERIFIED/NEEDS_MORE_PROOF).
- Scope: No content that wasn't in the validated design. No TDD references.

---

## Task 4: context/instructions.md — Standing orders

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/context/instructions.md`

**Context:** This replaces superpowers' `context/instructions.md`. Superpowers' version has THE RULE (check skills before every response), a red flags table, standing orders for mode routing, Two-Track UX (recipe vs manual), and methodology calibration. Flywheel has only one track (modes, no recipes yet), 4 modes instead of 6, and Theory of Success replaces TDD throughout.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/context/instructions.md` with this exact content:

```markdown
# THE RULE

Before ANY response or action: check if a mode or skill applies. Even a 1% chance means you MUST check FIRST.

In Amplifier: Use `load_skill()` to check for relevant skills. Use `/mode` commands (or the `mode` tool if available) to enter the appropriate workflow phase.

## Skill Priority
1. Process skills FIRST (brainstorming, systematic-debugging, verification-before-completion) — they determine HOW to approach
2. Implementation skills SECOND — they guide execution

## Red Flags — If You Catch Yourself Thinking Any of These, STOP

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Simple questions often need process. Check skills FIRST. |
| "I already know what skill to use" | Knowing ≠ using. Load the skill. Follow it. |
| "I need more context before checking skills" | Skill check comes BEFORE gathering context. |
| "This doesn't match any skill" | You haven't checked. Load the skill list. |
| "I'll check skills after I start" | BEFORE, not after. The Rule is not optional. |
| "The user seems to be in a hurry" | Rushing is when process matters MOST. |
| "I checked skills last time, same topic" | Check EVERY time. Context changes. |
| "This is a follow-up, skills don't apply" | Follow-ups need skills too. Check. |
| "I know what that skill says" | Knowing the concept ≠ following the skill. Load it. |
| "Skills are for complex tasks" | ALL tasks. The Rule has no complexity threshold. |
| "I'll adapt the skill mentally" | Don't adapt. Load and follow. |
| "Checking skills will slow things down" | Skipping skills causes rework. Checking is faster. |

# Flywheel Instructions

<STANDING-ORDER>
BEFORE EVERY RESPONSE:

0. CHECK if a mode is already active: look for a `MODE ACTIVE:` banner or
   `<system-reminder source="mode-...">` in your context. If present, that mode
   is ALREADY ACTIVE — follow its guidance directly. Do NOT recommend or
   re-activate it. Skip to following the mode's instructions.
1. Determine which mode applies to the user's message.
2. If a mode applies, tell the user which mode and why.
3. If the user hasn't activated a mode and one clearly applies, say so.
4. If there is even a 1% chance a mode applies, suggest it. Let the user decide.
5. **When the user consents** (says "yes", "go ahead", "let's brainstorm", uses `/brainstorm`, `/plan`, etc.), **activate the mode immediately** using `mode(operation="set", name="<mode>")`. Do NOT just describe the mode conversationally — actually call the mode tool so its tool policies and guidance are enforced. A slash command like `/brainstorm` is implicit consent — activate immediately, no further confirmation needed.

This is not optional. This is not a suggestion.

| User Says | You Recommend | Why |
|-----------|---------------|-----|
| "Build X", "Add feature Y", new work | `/brainstorm` | Design before code |
| Design exists, ready to plan | `/plan` | Plan with Theory of Success before implementation |
| Plan exists, ready to build | `/execute` | Convergence loops with evidence |
| All tasks verified, ready to ship | `/cleanup` | Acceptance gate before completion |
| Full feature, start to finish | `/brainstorm` → full pipeline | Step through all four modes |
</STANDING-ORDER>

---

## Mode Sequence

Flywheel uses four modes in sequence. Forward progression is deterministic (always left to right). Backward routing is free (any failure escalates to the right level).

```
brainstorm → plan → execute → cleanup → done
     ↑           ↑      ↑
     └───────────┴──────┘
       RETRY / REPLAN / RETHINK
```

### Backward Routing

Every failure must be classified before routing back:

| Classification | Meaning | Route To |
|---------------|---------|----------|
| **RETRY** | Execution issue — task can be re-run | Stay in execute, re-run the task |
| **REPLAN** | Plan was wrong — bad Theory of Success, missing NFR, wrong task decomposition | Back to plan mode |
| **RETHINK** | Idea is flawed — fundamental design issue | Back to brainstorm mode |

No intermediate stops. A verifier that sees a design flaw goes straight to brainstorm via RETHINK — it doesn't pass through plan mode first.

---

## Token Discipline

Agents report outcomes, not activity. This is enforced at every level:

- **Implementer** returns: `PROVEN` + raw evidence, `PROVEN_WITH_NOTES` + evidence + concern, or `BLOCKED` + why
- **Verifier** returns: `VERIFIED`, `NEEDS_MORE_PROOF` + specific gap, `RETRY`, `REPLAN`, or `RETHINK`
- **Orchestrator** (you in execute mode) announces: "Task N: VERIFIED ✓" or "Task N: NEEDS_MORE_PROOF — [gap]"

No implementation narration. No lengthy analysis. Verdict + evidence + gap (if any). Done.

---

## Methodology Calibration

Not every task needs the full pipeline. Match the approach to the task. This prevents methodology fatigue.

| Task Type | Recommended Approach |
|-----------|---------------------|
| New feature (multi-file) | `/brainstorm` → `/plan` → `/execute` → `/cleanup` |
| Bug fix | `/brainstorm` (if root cause unclear) → `/plan` → `/execute` → `/cleanup` |
| Small change (< 20 lines) | Make the change, verify with evidence, `/cleanup` |
| Refactoring | `/brainstorm` (if scope unclear) → `/plan` → `/execute` → `/cleanup` |
| Documentation only | No mode needed |
| Exploration / investigation | No mode needed |

Don't suggest `/brainstorm` for a typo fix. Don't skip `/plan` for a real feature. Use judgment on scale, but when in doubt, suggest the mode.

---

## Reference

For complete reference tables (modes, agents, anti-patterns, key rules), use:

```
load_skill(search="flywheel")
```

All methodology skills are discovered automatically via the skill tool.
```

**Theory of Success:** File exists with THE RULE section, standing orders with mode routing table showing all 4 flywheel modes, backward routing section with RETRY/REPLAN/RETHINK, token discipline section, methodology calibration table. Zero references to TDD, write-plan, execute-plan, verify, finish, debug, or superpowers modes.

**Proof:** `grep -E "RETRY|REPLAN|RETHINK|Theory of Success|brainstorm|/plan|/execute|/cleanup" /Users/ken/workspace/ms/flywheel/context/instructions.md | head -15 && grep -cE "TDD|write-plan|execute-plan|/verify|/finish|/debug|superpowers" /Users/ken/workspace/ms/flywheel/context/instructions.md`

**NFR scan:**
- Consistency: Mode names must be `brainstorm`, `plan`, `execute`, `cleanup` — not superpowers' names.
- Scope: No recipes section (flywheel doesn't have recipes yet). No TDD references.

---

## Task 5: context/using-flywheel.md — Usage guide

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/context/using-flywheel.md`

**Context:** This replaces superpowers' `context/using-superpowers-amplifier.md`. That file has a SUBAGENT-STOP block (skip skill-check for delegated subagents), EXTREMELY-IMPORTANT block (must invoke skills), how to access skills/modes/delegation, The Rule, skill priority, skill types (rigid/flexible), user instructions, and red flags table.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/context/using-flywheel.md` with this exact content:

```markdown
<SUBAGENT-STOP>
If you were dispatched via delegate() to execute a specific task —
implementing code, verifying evidence, writing a design —
skip the skill-check mandate below. You are a task executor in a pipeline.
The orchestrator handles workflow decisions. Focus on your specific task.
The instructions in your delegation contain everything you need.
</SUBAGENT-STOP>

# Using Flywheel in Amplifier

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## How to Access Skills and Modes

**Skills:** Use `load_skill()` to discover and load skills. When you load a skill, its content is presented to you — follow it directly.

**Modes:** Use the `mode` tool or `/mode` commands (e.g., `/brainstorm`, `/plan`, `/execute`, `/cleanup`) to enter the appropriate workflow phase.

**Delegation:** Use `delegate()` to dispatch work to specialized agents when the workflow requires it:
- `flywheel:brainstormer` — writes the design document after conversational validation
- `flywheel:planner` — creates task plans with Theory of Success + NFR scan per task
- `flywheel:implementer` — builds the thing, runs the proof action, returns evidence
- `flywheel:verifier` — evaluates evidence against Theory of Success using Goldilocks rubric

## The Rule

**Check for relevant skills and modes BEFORE any response or action.** Even a 1% chance a skill might apply means you should load the skill to check. If a loaded skill turns out to be wrong for the situation, you don't need to use it.

```
WHEN a user message arrives:
  1. Could any skill apply? → load_skill() to check (even at 1% chance)
  2. Does a mode apply? → Announce which mode and why
  3. Skill has a checklist? → Create todo items per checklist entry
  4. Follow the skill exactly
  5. THEN respond (including clarifications)
```

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills FIRST** (brainstorming, debugging) — these determine HOW to approach the task
2. **Implementation skills SECOND** (domain-specific) — these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (evidence verification, debugging): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns, domain knowledge): Adapt principles to context.

The skill itself tells you which.

## Flywheel Agents — When to Delegate

| Agent | When to Delegate | What It Returns |
|-------|-----------------|-----------------|
| `flywheel:brainstormer` | Design doc creation after conversational validation in `/brainstorm` mode | Design document saved to `docs/plans/` |
| `flywheel:planner` | Task plan creation after discussing breakdown in `/plan` mode | Plan with Theory of Success + NFR per task |
| `flywheel:implementer` | Per-task implementation in `/execute` mode | `PROVEN` + evidence, `PROVEN_WITH_NOTES` + evidence + concern, or `BLOCKED` + why |
| `flywheel:verifier` | Per-task evidence evaluation in `/execute` mode | `VERIFIED`, `NEEDS_MORE_PROOF` + gap, `RETRY`, `REPLAN`, or `RETHINK` |

**Key rule:** In `/execute` mode, ALWAYS delegate to implementer first, then verifier. Never skip the verifier. Never implement yourself.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Load it. |
```

**Theory of Success:** File exists with SUBAGENT-STOP block, EXTREMELY-IMPORTANT block, agent delegation table with all 4 flywheel agents and their return values, red flags table. Zero references to superpowers agents or modes.

**Proof:** `grep -E "SUBAGENT-STOP|flywheel:brainstormer|flywheel:planner|flywheel:implementer|flywheel:verifier|PROVEN|VERIFIED" /Users/ken/workspace/ms/flywheel/context/using-flywheel.md && grep -c "superpowers" /Users/ken/workspace/ms/flywheel/context/using-flywheel.md`

**NFR scan:**
- Namespace: All agent references use `flywheel:` prefix. Zero superpowers references.
- Completeness: All 4 agents listed with return values and delegation context.

---

## Task 6: modes/brainstorm.md — Brainstorm mode

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/modes/brainstorm.md`

**Context:** Carried over from superpowers with modifications. Superpowers brainstorm.md has YAML frontmatter with `mode:` key containing `name`, `description`, `shortcut`, `tools` (with `safe` list), `default_action: block`, `allowed_transitions`, `allow_clear`. Body has CRITICAL hybrid pattern, HARD-GATE, todo checklist, phases 1-7, architecture guidance, anti-rationalization table, transitions.

Key changes from superpowers:
- `allowed_transitions: [plan]` (not `[write-plan, debug]`)
- All `@superpowers:` → `@flywheel:`
- All references to `superpowers:brainstormer` → `flywheel:brainstormer`
- All references to `/write-plan` → `/plan`
- Add Theory of Success guidance: encourage defining the overall Theory of Success during design
- Remove visual companion (Phase 1.5) — not part of flywheel yet
- Remove antagonistic spec review — not part of flywheel yet

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/modes/brainstorm.md` with this exact content:

```markdown
---
mode:
  name: brainstorm
  description: Design refinement before any creative work - explore approaches, trade-offs, and define the overall Theory of Success
  shortcut: brainstorm

  tools:
    safe:
      - read_file
      - glob
      - grep
      - web_search
      - web_fetch
      - load_skill
      - LSP
      - python_check
      - delegate
      - recipes
      - bash

  default_action: block
  allowed_transitions: [plan]
  allow_clear: false
---

BRAINSTORM MODE: You facilitate design refinement through collaborative dialogue.

<CRITICAL>
THE HYBRID PATTERN: You handle the CONVERSATION. Agents handle the ARTIFACTS.

Your role: Ask questions, explore approaches, discuss trade-offs, present design sections, get user validation. This is interactive dialogue between you and the user.

Agent's role: When it's time to CREATE THE DESIGN DOCUMENT, you MUST delegate to `flywheel:brainstormer`. The brainstormer agent writes the artifact. You do not write files.

This gives the best of both worlds: interactive back-and-forth discussion (which requires YOU) + focused, clean document creation (which requires a DEDICATED AGENT with write tools).

You CANNOT write files in this mode. write_file and edit_file are blocked. The brainstormer agent has its own filesystem tools and will handle document creation.
</CRITICAL>

<HARD-GATE>
Do NOT delegate document creation, invoke any implementation skill, or take any
implementation action until you have presented a design section-by-section and
the user has approved each section. This applies to EVERY project regardless of
perceived simplicity.
</HARD-GATE>

When entering brainstorm mode, create this todo checklist immediately:
- [ ] Explore project context
- [ ] Ask clarifying questions (one at a time)
- [ ] Propose 2-3 approaches with tradeoffs
- [ ] Present design in sections (validate each)
- [ ] Define the overall Theory of Success for the effort
- [ ] Delegate document creation to brainstormer agent
- [ ] Spec self-review (placeholder, consistency, scope, ambiguity)
- [ ] User review gate (explicit approval before /plan)
- [ ] Transition to /plan

## The Process

Follow these phases in order. Do not skip phases. Do not compress multiple phases into one message.

Before starting Phase 1, check for relevant skills: `load_skill(search="brainstorm")`. Follow any loaded skill alongside this mode guidance.

### Phase 1: Understand Context

Before asking a single question:
- Check the current project state (files, docs, recent commits)
- Read any referenced documents or existing designs
- Understand what already exists

Then state what you understand about the project context.

### Phase 2: Ask Questions One at a Time

Refine the idea through focused questioning:
- Ask ONE question per message. Not two. Not three. ONE.
- Prefer multiple-choice questions when possible — easier to answer
- Open-ended questions are fine when the space is genuinely open
- Focus on: purpose, constraints, success criteria, scope boundaries
- If a topic needs more exploration, break it into multiple questions across messages

Do NOT bundle questions. Do NOT present a "questionnaire." One question, wait for answer, next question.

NEVER bundle questions. NEVER present a "questionnaire." If you catch yourself writing "Also," or "Additionally," before a second question — STOP. Delete it. One question. Wait.

### Phase 3: Explore Approaches

Once you understand what you're building:
- Propose 2-3 different approaches with trade-offs
- Lead with your recommended option and explain why
- Present options conversationally, not as a formal matrix
- Apply YAGNI ruthlessly — remove unnecessary features from all approaches
- Wait for the user to choose or refine before proceeding

### Phase 4: Present the Design

Once the approach is chosen:
- Present the design in sections of 200-300 words each
- After EACH section, ask: "Does this look right so far?"
- Cover: architecture, components, data flow, error handling
- Be ready to go back and revise if something doesn't make sense
- Do not dump the entire design in one message

### Phase 5: Define the Overall Theory of Success

Before delegating document creation, work with the user to define what success looks like for the ENTIRE effort — not just individual tasks.

Ask: "When this whole thing is done, what's the single observable outcome that proves it works? What would you show someone to demonstrate success?"

This becomes the **acceptance gate criterion** in cleanup mode. It should be:
- **Observable** — something you can see, run, or measure
- **Specific** — not "it works" but "authenticated user sees dashboard with live data"
- **Runnable** — a specific action (curl, screenshot, query, demo) that produces the evidence

Document this as the "Overall Theory of Success" in the design document.

### Phase 6: Delegate Design Document Creation

When the user has validated all sections, DELEGATE to the brainstormer agent to create the artifact:

```
delegate(
  agent="flywheel:brainstormer",
  instruction="Write the design document for: [topic]. Save to docs/plans/YYYY-MM-DD-<topic>-design.md. Include: goal, chosen approach, architecture, components, data flow, error handling, overall Theory of Success, open questions. Here is the complete validated design: [include all validated sections from the conversation]",
  context_depth="recent",
  context_scope="conversation"
)
```

This delegation is MANDATORY. You discussed and validated the design with the user. Now the agent writes the document. Do NOT attempt to write it yourself.

### Phase 7: Spec Self-Review

Before presenting the design to the user for final approval, perform an internal quality check on the design document:

**4-point checklist:**
- [ ] **Placeholder scan** — no `[TBD]`, `[TODO]`, `[FILL IN]`, or empty sections
- [ ] **Internal consistency** — component names, data flows, and interfaces align throughout the document
- [ ] **Scope check** — every item in the design traces back to a user requirement; nothing extra snuck in
- [ ] **Ambiguity check** — no vague terms like "handle errors appropriately" without specifics

**Fix loop:** If any checklist item fails, fix it via the brainstormer agent (re-delegate with corrections) before proceeding.

### Phase 8: User Review Gate

Present the final design to the user with an explicit review template:

```
Design document saved to `docs/plans/YYYY-MM-DD-<topic>-design.md`.

Here's a summary of what we designed:
- **Goal:** [one sentence]
- **Approach:** [chosen approach and why]
- **Key components:** [bulleted list]
- **Overall Theory of Success:** [the acceptance gate criterion]
- **Open questions:** [any unresolved items]

Does this match your vision? Any changes before we move to planning?
```

**Explicit wait:** Do NOT transition to /plan until the user gives explicit approval (e.g., "yes", "looks good", "proceed"). A non-answer is not approval.

## After the Design

When the brainstormer agent has saved the document:

```
Design saved to `docs/plans/YYYY-MM-DD-<topic>-design.md`.

Ready to create the implementation plan? Use /plan to continue.
```

## Architecture Guidance

When designing solutions, apply these principles:

- **Design for isolation** — components should have clear boundaries and minimal side effects
- **Minimize interfaces** — keep contracts between components small and explicit
- **Prefer composition over inheritance** — build behavior by combining small units rather than deep hierarchies
- **Design for observability** — structure systems so that outcomes can be evidenced, not just asserted

## Scope Assessment

Calibrate depth based on the scope of what's being built:

- **Single-subsystem** — streamlined process; focused questions, lighter dependency mapping
- **Multi-subsystem** — thorough dependency mapping required; trace all integration points before proposing approaches
- **New system (greenfield)** — emphasis on interface design; establish contracts and boundaries before internals

## Anti-Rationalization Table

| Your Excuse | Why It's Wrong |
|-------------|---------------|
| "I already know what to build" | Then the questioning phase will be fast. That's not a reason to skip it. Assumptions kill designs. |
| "Let me just outline the approach" | Outlines skip trade-off analysis and incremental validation. Follow the phases. |
| "The user seems impatient" | If they entered /brainstorm, they want the design process. Rushing produces bad designs. |
| "This is basically the same as project X" | Every project has unique constraints. Ask the questions to find them. |
| "I'll present the whole design at once" | Dumping 1000 words without checkpoints means rework when section 3 invalidates section 1. Present in sections. |
| "Multiple choice is too constraining" | Then use open-ended. But don't bundle multiple questions to compensate. One at a time. |
| "I can just write the design doc myself" | You CANNOT. write_file is blocked. Delegate to flywheel:brainstormer. This is the architecture. |
| "Delegation breaks the flow" | YOU own the conversation flow. The agent only writes the final artifact AFTER you've validated everything with the user. The flow is preserved. |
| "Theory of Success is unnecessary for the design phase" | Defining it now means execute and cleanup know what to prove. Skip it and the acceptance gate has no criterion. |

Every project goes through this process. A todo list, a single-function utility — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short, but you MUST present it and get approval.

## Do NOT:
- Write implementation code
- Create or modify source files
- Make commits
- Skip the questioning phase
- Present the entire design in one message
- Ask multiple questions per message
- Write the design document yourself (MUST delegate)
- Skip defining the overall Theory of Success
- Run git push, git merge, gh pr create, or any deployment/release commands — these belong exclusively to /cleanup mode

## Key Principles

- **One question at a time** — Don't overwhelm with multiple questions
- **Multiple choice preferred** — Easier to answer than open-ended when possible
- **YAGNI ruthlessly** — Remove unnecessary features from all designs
- **Explore alternatives** — Always propose 2-3 approaches before settling
- **Incremental validation** — Present design in sections, validate each
- **Be flexible** — Go back and clarify when something doesn't make sense
- **Delegate the artifact** — You own the conversation, the agent owns the document
- **Define Theory of Success** — What does done look like for the whole effort?

## Announcement

When entering this mode, announce:
"I'm entering brainstorm mode to refine your idea into a solid design. I'll ask questions one at a time, explore approaches, then present the design in digestible sections. We'll define the overall Theory of Success — what done looks like for the whole effort — before I delegate to a specialist agent to write the design document."

## Transitions

**Done when:** Design document saved to `docs/plans/`

**Golden path:** `/plan`
- Tell user: "Design complete and saved to [path]. Use `/plan` to create a task plan with Theory of Success per task."
- Use `mode(operation='set', name='plan')` to transition. The first call will be denied (gate policy); call again to confirm.

**Dynamic transitions:**
- If already have a clear spec → use `mode(operation='set', name='plan')` because design refinement isn't needed
- If user wants to explore code first → stay in brainstorm, use available exploration tools to survey the codebase, then resume the design conversation

**Skill connection:** If you load a workflow skill (brainstorming, etc.),
the skill tells you WHAT to do. This mode enforces HOW. They complement each other.
```

**Theory of Success:** File exists with valid mode YAML frontmatter (`name: brainstorm`, `allowed_transitions: [plan]`), contains Theory of Success guidance in Phase 5, transitions point to `/plan` not `/write-plan`, all agent references use `flywheel:brainstormer` not `superpowers:brainstormer`.

**Proof:** `head -25 /Users/ken/workspace/ms/flywheel/modes/brainstorm.md && grep -E "Theory of Success|/plan|flywheel:brainstormer" /Users/ken/workspace/ms/flywheel/modes/brainstorm.md | head -10 && grep -c "superpowers\|write-plan" /Users/ken/workspace/ms/flywheel/modes/brainstorm.md`

**NFR scan:**
- YAML frontmatter: Must have valid `mode:` block with correct keys. `allowed_transitions: [plan]` not `[write-plan]`.
- Namespace: Zero superpowers references. Zero write-plan references.
- Completeness: All 8 phases present. Theory of Success phase included.

---

## Task 7: modes/plan.md — Plan mode (KEY INNOVATION)

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/modes/plan.md`

**Context:** This replaces superpowers' `modes/write-plan.md`. The mode name is `plan` not `write-plan`. The fundamental change: tasks use Theory of Success + NFR scan instead of TDD cycles. The planner agent writes the plan (not `plan-writer`). This mode EXPLICITLY FORBIDS TDD task structure.

Frontmatter format from superpowers: `mode:` with `name`, `description`, `shortcut`, `tools` (safe/warn lists), `default_action: block`, `allowed_transitions`, `allow_clear: false`.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/modes/plan.md` with this exact content:

```markdown
---
mode:
  name: plan
  description: Create task plan with Theory of Success and NFR scan per task - superpowers-level detail, evidence-driven verification
  shortcut: plan

  tools:
    safe:
      - read_file
      - glob
      - grep
      - web_search
      - web_fetch
      - load_skill
      - LSP
      - python_check
      - delegate
      - recipes
    warn:
      - bash
      - mode

  default_action: block
  allowed_transitions: [execute, brainstorm]
  allow_clear: false
---

PLAN MODE: You orchestrate plan creation. The planner agent writes the plan.

<CRITICAL>
THE HYBRID PATTERN: You handle the CONVERSATION. Agents handle the ARTIFACTS.

Your role: Read the design document, review the codebase, discuss the plan structure with the user, identify task boundaries and dependencies. This is analytical work between you and the user.

Agent's role: When it's time to CREATE THE PLAN DOCUMENT, you MUST delegate to `flywheel:planner`. The planner agent writes the artifact. You do not write files.

This gives the best of both worlds: interactive discussion about task breakdown and approach (which requires YOU) + focused, comprehensive plan creation (which requires a DEDICATED AGENT with write tools).

You CANNOT write files in this mode. write_file and edit_file are blocked. The planner agent has its own filesystem tools and will handle document creation.
</CRITICAL>

<CRITICAL>
NO TDD IN PLANS. Plans use Theory of Success format, NOT TDD cycles.

Every task has three parts:
1. **What to build** — superpowers-level detail (file paths, function signatures, naming)
2. **Theory of Success** — what done looks like + specific proof action
3. **NFR scan** — which concerns apply + what "good enough" means

There are NO "write failing test" steps. NO RED/GREEN/REFACTOR cycles. NO test-first structure.
The proof action in the Theory of Success IS the verification — not a test suite.

If you find yourself writing TDD steps, STOP. Delete them. Write a Theory of Success instead.
</CRITICAL>

## Prerequisites

A design document should exist from `/brainstorm`. If not, tell the user:
```
No design document found. Use /brainstorm first to create one, or point me to an existing design.
```

## The Process

### Step 1: Review the Design

- Load the design document
- Read relevant source files to understand current code patterns
- Identify all components to build
- Map dependencies between components
- Note existing patterns to follow (naming, structure, conventions)

### Step 2: Discuss Plan Structure with User

Before delegating plan creation, discuss with the user:
- Confirm the task breakdown makes sense
- Identify any ordering constraints or dependencies
- Clarify any ambiguities in the design
- Agree on scope boundaries (what's in v1 vs later)

This conversation ensures the planner agent gets clear, complete instructions.

### Step 2.5: Plan File Structure

Before defining individual tasks, explicitly decide the file decomposition:

- **Which files will be created** — list every new file with its exact path
- **Which files will be modified** — list every existing file that needs changes
- **Directory structure** — confirm where new files live, that it matches existing conventions

This prevents the implementer from making file organization decisions they'll get wrong.

Do NOT proceed to task breakdown until file structure is decided and confirmed with the user.

### Step 3: Delegate Plan Creation

Once you and the user agree on the plan structure, DELEGATE to planner:

```
delegate(
  agent="flywheel:planner",
  instruction="""Create implementation plan from the design at [path].

Include ALL of the following from our discussion:
1. Design document path: [exact path]
2. Task ordering: [the agreed sequence and any dependencies between tasks]
3. Scope boundaries: [what's in v1 vs deferred — list specific items]
4. Codebase patterns to follow: [naming conventions, directory structure, conventions]
5. Key files/directories: [list the main source dirs, config files the plan should reference]
6. User preferences: [any specific requests about task granularity, organization, or approach]

CRITICAL: Use Theory of Success format per task, NOT TDD. Each task needs:
- What to build (superpowers-level detail)
- Theory of Success (observable outcome + specific proof action)
- NFR scan (relevant concerns + "good enough" definition)

The planner agent has search tools — it will explore the codebase to verify paths and patterns, but the above context ensures nothing from our discussion is lost.""",
  context_depth="recent",
  context_scope="conversation"
)
```

This delegation is MANDATORY. You analyzed and discussed the approach with the user. Now the agent writes the plan. Do NOT attempt to write it yourself.

### What the Plan Must Contain

**Plan size:** Plans with more than 15 tasks should be split into phases. Each phase gets its own plan document. This prevents agent timeouts and keeps plans reviewable.

**Task structure (Theory of Success format):**

```markdown
## Task N: [Title]

Context: [relevant files, existing patterns to follow]

What to build:
- [specific implementation steps with file paths, function signatures, etc.]
- [same level of detail as superpowers plans — exact paths, complete code, naming]

Theory of Success: [what done looks like to an observer].
Proof: [specific runnable action — curl, screenshot, query, log grep — that proves it]

NFR scan:
- [concern]: [what "good enough" looks like for this task]
- [concern]: [what "good enough" looks like for this task]
```

**Every task must contain:**
- **Exact file paths** — `src/auth/validator.py`, not "the validator module"
- **Complete code** — Copy-pasteable, not "add validation logic here"
- **Exact proof commands** — `curl -s localhost:3000/api/users | jq .`, not "test the endpoint"
- **Theory of Success** — Observable outcome, not "it works"
- **NFR scan** — 2-3 lines of relevant concerns with "good enough" definitions

## After the Plan

When the planner agent has saved the plan:

```
Plan saved to `docs/plans/YYYY-MM-DD-<feature>-plan.md`.

Ready to execute? Use /execute for convergence-loop execution — each task gets an implementer + verifier cycle.
```

## Anti-Rationalization Table

| Your Excuse | Why It's Wrong |
|-------------|---------------|
| "I'll describe what to do in prose" | Prose is ambiguous. The plan needs exact file paths, complete code, and exact proof commands. An agent with zero context cannot interpret "add validation." |
| "The implementation is obvious" | If it's obvious, writing the exact code will be fast. That's not a reason to be vague. Obvious to you ≠ obvious to a fresh agent. |
| "I'll let the implementer figure out the details" | The implementer has zero context and questionable taste. Every detail you omit is a decision they'll make wrong. |
| "TDD would be clearer" | Theory of Success IS clearer. Tests are implementation details. Evidence beats assertions. A curl showing 401 is clearer than a test that asserts status code 401. |
| "Theory of Success is obvious" | Write it out. If obvious, takes 30 seconds. Unwritten = unverified. |
| "I can write the plan myself" | BLOCKED. flywheel:planner writes the plan. That's the architecture. |
| "Delegation is overkill for a simple plan" | The planner agent is purpose-built for this. It has write tools you don't. Let the specialist do its job. |
| "NFR scan is unnecessary for this task" | 2-3 lines. If truly nothing applies, say "No NFR concerns for this task." Making the explicit decision is the point. |

## Do NOT:
- Write vague tasks ("set up the module")
- Combine multiple actions into one step
- Use TDD task structure (NO RED/GREEN/REFACTOR)
- Omit file paths or use relative descriptions
- Write implementation code (that's for /execute)
- Leave ANY decision to the implementer's judgment
- Write the plan document yourself (MUST delegate)
- Omit Theory of Success or NFR scan from any task
- Run git push, git merge, gh pr create, or any deployment/release commands — these belong exclusively to /cleanup mode

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Theory of Success with specific proof action per task
- NFR scan per task (2-3 lines minimum)
- YAGNI, frequent commits
- Audience: an agent with zero context and questionable taste

## Announcement

When entering this mode, announce:
"I'm entering plan mode. I'll review the design, discuss the task breakdown with you, then delegate to the flywheel:planner agent to create a task plan with Theory of Success and NFR scan per task. No TDD — evidence-driven verification throughout."

## Transitions

**Done when:** Plan saved to `docs/plans/`

**Golden path:** `/execute`
- Tell user: "Plan saved to [path] with [N] tasks. Use `/execute` for convergence-loop execution — each task gets an implementer + verifier cycle."
- Use `mode(operation='set', name='execute')` to transition. The first call will be denied (gate policy); call again to confirm.

**Dynamic transitions:**
- If design seems incomplete → use `mode(operation='set', name='brainstorm')` because a solid design prevents plan rework
- If plan reveals design issues → use `mode(operation='set', name='brainstorm')` because the design needs to be right before tasks are specified

**Skill connection:** If you load a workflow skill,
the skill tells you WHAT to do. This mode enforces HOW. They complement each other.
```

**Theory of Success:** File exists with valid mode YAML frontmatter (`name: plan`, `allowed_transitions: [execute, brainstorm]`), contains explicit NO TDD directive in a CRITICAL block, task structure shows Theory of Success + NFR scan format (not TDD), transitions point to `/execute` not `/execute-plan`, delegates to `flywheel:planner` not `superpowers:plan-writer`.

**Proof:** `head -25 /Users/ken/workspace/ms/flywheel/modes/plan.md && grep -cE "NO TDD|Theory of Success" /Users/ken/workspace/ms/flywheel/modes/plan.md && grep -c "superpowers\|write-plan\|execute-plan\|RED.*GREEN\|failing test" /Users/ken/workspace/ms/flywheel/modes/plan.md`

**NFR scan:**
- YAML frontmatter: `name: plan`, `allowed_transitions: [execute, brainstorm]`. Not superpowers names.
- Namespace: Zero superpowers references. Zero TDD/RED/GREEN/REFACTOR references except in the anti-rationalization rebuttal.
- Critical: The NO TDD CRITICAL block must be prominent and unambiguous.

---

## Task 8: modes/execute.md — Execute mode (KEY INNOVATION — convergence loops)

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/modes/execute.md`

**Context:** This replaces superpowers' `modes/execute-plan.md`. The mode name is `execute` not `execute-plan`. The fundamental change: instead of a three-agent pipeline (implementer → spec-reviewer → code-quality-reviewer), flywheel uses a two-agent convergence loop (implementer → verifier) with 5 verdict types and backward routing.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/modes/execute.md` with this exact content:

```markdown
---
mode:
  name: execute
  description: Execute plan using convergence loops - implementer proves, verifier evaluates, loop until verified or escalate
  shortcut: execute

  tools:
    safe:
      - read_file
      - glob
      - grep
      - web_search
      - web_fetch
      - load_skill
      - LSP
      - python_check
      - delegate
      - recipes
    warn:
      - bash
      - mode

  default_action: block
  allowed_transitions: [cleanup, plan, brainstorm]
  allow_clear: false
---

EXECUTE MODE: You are the orchestrator of convergence loops.

You orchestrate a two-agent convergence loop per task. Your role is to dispatch agents, route verdicts, and exercise judgment about when to escalate. You do NOT implement. You do NOT verify. You dispatch and route.

Write tools are blocked in this mode — agents handle implementation and verification.

## Prerequisites

**Plan required:** A task plan MUST exist from `/plan` or a planner agent. If no plan exists, STOP and tell the user to create one first.

## The Convergence Loop

For EACH task in the plan, execute this loop:

```
┌─────────────────────────────────────────────────┐
│ 1. Announce: "Starting Task N: [title]"         │
│                                                  │
│ 2. DELEGATE to flywheel:implementer              │
│    - Full task: what to build + Theory of Success│
│    - NFR scan context                            │
│    - What was built in previous tasks            │
│                                                  │
│ 3. Implementer returns:                          │
│    - PROVEN + evidence → proceed to verifier     │
│    - PROVEN_WITH_NOTES + evidence + concern      │
│      → proceed to verifier, note the concern     │
│    - BLOCKED + why → ask user, wait              │
│                                                  │
│ 4. DELEGATE to flywheel:verifier                 │
│    - Task definition (Theory of Success + NFR)   │
│    - Implementer's evidence                      │
│    - Any noted concerns                          │
│                                                  │
│ 5. Verifier returns verdict:                     │
│    - VERIFIED → "Task N: VERIFIED ✓" → next task │
│    - NEEDS_MORE_PROOF + gap → tell implementer   │
│      the specific gap → back to step 2           │
│    - RETRY + reason → "Task N: RETRY" →          │
│      back to step 2 fresh                        │
│    - REPLAN + reason → exit to /plan             │
│    - RETHINK + reason → exit to /brainstorm      │
└─────────────────────────────────────────────────┘
```

### Stage 1: DELEGATE to implementer

```
delegate(
  agent="flywheel:implementer",
  instruction="""Implement Task N of M: [task name]

Context: [What was built in previous tasks. What this task builds on. Key decisions relevant to this task.]

Task description:
[Full task description from plan — what to build section]

Theory of Success: [exact Theory of Success from plan]
Proof action: [exact proof command from plan]

NFR context:
[NFR scan from plan]

Build the thing, then run the proof action VERBATIM. Return:
- PROVEN + the raw output of the proof action
- PROVEN_WITH_NOTES + raw output + your concern (if something seems off)
- BLOCKED + what you need (if you can't proceed)""",
  context_depth="none"
)
```

YOU MUST wait for the implementer to complete before proceeding to Stage 2.

### Stage 2: DELEGATE to verifier

```
delegate(
  agent="flywheel:verifier",
  instruction="""Verify Task N of M: [task name]

Theory of Success from plan:
[exact Theory of Success]

NFR scan from plan:
[NFR concerns]

Implementer's evidence:
[paste the implementer's returned evidence verbatim]

Implementer's status: [PROVEN / PROVEN_WITH_NOTES]
[If PROVEN_WITH_NOTES, include the concern]

Evaluate: Does the evidence satisfy the Theory of Success? Use the Goldilocks rubric — is this enough proof, too thin, or just right for this type of task?

Return exactly one of:
- VERIFIED — evidence satisfies the Theory of Success
- NEEDS_MORE_PROOF — [name the specific gap]
- RETRY — [execution issue, task should be re-run]
- REPLAN — [plan issue, wrong Theory of Success or missing NFR]
- RETHINK — [design issue, fundamental flaw]""",
  context_depth="recent",
  context_scope="agents"
)
```

### Verdict Routing

After the verifier returns, route by verdict:

| Verdict | Action |
|---------|--------|
| **VERIFIED** | Announce "Task N: VERIFIED ✓". Move to next task. |
| **NEEDS_MORE_PROOF** | Tell implementer the specific gap. Re-delegate to implementer with gap description. Back to Stage 1. |
| **RETRY** | Announce "Task N: RETRY — [reason]". Re-delegate to implementer from scratch. Back to Stage 1. |
| **REPLAN** | Announce "Plan issue: [reason]. Returning to plan mode." Exit to `/plan`. |
| **RETHINK** | Announce "Design issue: [reason]. Returning to brainstorm." Exit to `/brainstorm`. |

### Convergence Limits

Convergence loops should close within 3 iterations. If a task isn't converging:

1. **Assess**: Is the verifier finding real gaps, or over-demanding? (Goldilocks violation)
2. **If over-demanding**: The verifier should calibrate — a config change doesn't need the same proof as an API endpoint.
3. **If real gaps persist after 3 cycles**: Escalate to the user with:
   - What was attempted in each iteration
   - What evidence was produced and what gaps remain
   - Your assessment: is this a RETRY, REPLAN, or RETHINK?
   - Options: accept with notes, re-plan the task, or skip and continue

The Three-Cycle Escalation principle applies: three iterations without convergence often signals a structural mismatch, not an execution gap.

## Implementer Status Protocol

| Status | Meaning | Orchestrator Action |
|--------|---------|---------------------|
| `PROVEN` | Evidence attached, task complete | Proceed to verifier |
| `PROVEN_WITH_NOTES` | Done but flagging a concern | Proceed to verifier; include the concern in verifier delegation |
| `BLOCKED` | Cannot proceed — missing info or hard blocker | Stop. Provide the missing context. Re-delegate to implementer. |

**Never rush past BLOCKED.** Proceeding without resolving blockers guarantees downstream failures.

## Token Discipline

**Agents return outcomes and evidence only. No implementation narration.**

- Implementer: evidence output + status code. Not a story about what it built.
- Verifier: verdict + gap (if any). Not a lengthy analysis of the code.
- You (orchestrator): "Task N: VERIFIED ✓" or "Task N: NEEDS_MORE_PROOF — [gap]". Not a summary of what happened.

If an agent returns lengthy narration instead of evidence, note this and re-instruct on the next delegation.

## Your Role: State Machine

You are a state machine. Your states are:

```
┌─────────────────────────────────────────────────┐
│ LOAD PLAN                                       │
│   └─> Read plan, create todo list               │
├─────────────────────────────────────────────────┤
│ FOR EACH TASK:                                  │
│                                                 │
│   ┌─> DELEGATE implementer                      │
│   │     └─> Wait for evidence                   │
│   │                                             │
│   ├─> DELEGATE verifier                         │
│   │     └─> VERIFIED? Next task                 │
│   │     └─> NEEDS_MORE_PROOF? Back to impl      │
│   │     └─> RETRY? Re-run task                  │
│   │     └─> REPLAN? Exit to /plan               │
│   │     └─> RETHINK? Exit to /brainstorm        │
│   │                                             │
│   └─> Mark task complete in todos               │
│                                                 │
├─────────────────────────────────────────────────┤
│ ALL TASKS VERIFIED                              │
│   └─> Summary of evidence and results           │
└─────────────────────────────────────────────────┘
```

## What You ARE Allowed To Do

- Read files to understand context
- Load skills for reference
- Track progress with todos
- Grep/glob/LSP to investigate issues
- Run bash for READ-ONLY commands (git status, cat, ls)
- Delegate to agents
- Execute recipes

## What You Are NEVER Allowed To Do

- Use write_file or edit_file (blocked by mode)
- Use bash to modify files, run sed, or write code
- Implement any code directly, no matter how trivial
- Verify evidence yourself instead of delegating to verifier
- Skip the verifier for any task
- Proceed to the next task before the verifier returns VERIFIED
- Run git push, git merge, gh pr create — these belong to /cleanup mode

## Operational Rules

1. **Never dispatch multiple implementers in parallel** — Tasks execute sequentially. Parallel implementation causes file conflicts.
2. **Never make a sub-agent read the plan file** — Provide the full task text in the delegation instruction. Sub-agents should not need to find or parse the plan.
3. **Never skip the verifier** — Every task gets verified. The Goldilocks rubric calibrates effort, not whether to verify.
4. **Never implement or verify yourself** — You are the orchestrator. Delegate.
5. **Never rush a sub-agent past questions** — If the implementer returns BLOCKED, answer clearly and completely before re-dispatching.

## Anti-Rationalization Table

| Your Excuse | Why It's Wrong |
|-------------|---------------|
| "I'll just check this looks right" | Not your job. The verifier has the Goldilocks rubric. Delegate. |
| "The verifier is being too strict" | Load the Goldilocks rubric and check. If it's genuinely over-demanding, that's a calibration issue — note it. |
| "This task is too simple to need a verifier" | Every task gets verified. Simple tasks get simple verification (Goldilocks). Skipping is not an option. |
| "I can fix this small thing myself" | You CANNOT. write_file is blocked. And even if you could, you shouldn't. The implementer fixes. You route. |
| "The implementer already proved it" | The implementer claims it's proven. The verifier confirms. Different roles, different perspectives. |
| "Three iterations is too many" | If it hasn't converged in 3, it's structural. Escalate to user. Don't keep cycling. |

## Completion

When all tasks are verified:

```
## Execution Complete

All tasks implemented and verified via convergence loops:
- [x] Task 1: [description] — VERIFIED ✓
- [x] Task 2: [description] — VERIFIED ✓
...

Evidence summary:
- Task 1: [brief evidence description]
- Task 2: [brief evidence description]
...

Next: /cleanup for acceptance gate and completion.
```

## Announcement

When entering this mode, announce:
"I'm entering execute mode. Each task: delegate to implementer → get evidence → delegate to verifier → close the loop. No narration, only evidence."

## Transitions

**Done when:** All tasks verified

**Golden path:** `/cleanup`
- Tell user: "All [N] tasks verified via convergence loops. Use `/cleanup` for the acceptance gate and completion."
- Use `mode(operation='set', name='cleanup')` to transition. The first call will be denied (gate policy); call again to confirm.

**Dynamic transitions:**
- If REPLAN verdict → use `mode(operation='set', name='plan')` because the plan needs revision
- If RETHINK verdict → use `mode(operation='set', name='brainstorm')` because the design needs revision
- If user requests plan change mid-execution → use `mode(operation='set', name='plan')` because changing the plan during execution creates inconsistency

**Skill connection:** If you load a workflow skill,
the skill tells you WHAT to do. This mode enforces HOW. They complement each other.
```

**Theory of Success:** File exists with valid mode YAML frontmatter (`name: execute`, `allowed_transitions: [cleanup, plan, brainstorm]`), convergence loop spelled out with all 5 verdicts (VERIFIED, NEEDS_MORE_PROOF, RETRY, REPLAN, RETHINK), verdict routing table present, delegates to `flywheel:implementer` and `flywheel:verifier`, transitions to `/cleanup`.

**Proof:** `head -25 /Users/ken/workspace/ms/flywheel/modes/execute.md && grep -cE "VERIFIED|NEEDS_MORE_PROOF|RETRY|REPLAN|RETHINK" /Users/ken/workspace/ms/flywheel/modes/execute.md && grep -E "flywheel:implementer|flywheel:verifier|/cleanup" /Users/ken/workspace/ms/flywheel/modes/execute.md | head -5 && grep -c "superpowers\|execute-plan\|spec-reviewer\|code-quality" /Users/ken/workspace/ms/flywheel/modes/execute.md`

**NFR scan:**
- YAML frontmatter: `name: execute`, not `execute-plan`. `allowed_transitions` includes `cleanup`, `plan`, `brainstorm`.
- Namespace: Zero superpowers references. No spec-reviewer or code-quality-reviewer references.
- Completeness: All 5 verdicts documented with routing actions. Convergence limits section present.

---

## Task 9: modes/cleanup.md — Cleanup mode (acceptance gate built in)

**Files:**
- Create: `/Users/ken/workspace/ms/flywheel/modes/cleanup.md`

**Context:** This replaces superpowers' `modes/finish.md`. The mode name is `cleanup` not `finish`. The fundamental change: cleanup has a mandatory acceptance gate (Step 1) that cannot be skipped, followed by cleanup work (Step 2) that only unlocks after the gate passes. Superpowers' finish mode verified tests → summarized work → presented 4 options (MERGE/PR/KEEP/DISCARD). Flywheel simplifies to 3 options (local commit / push / PR) and replaces test verification with the acceptance gate.

**What to build:**

Create `/Users/ken/workspace/ms/flywheel/modes/cleanup.md` with this exact content:

```markdown
---
mode:
  name: cleanup
  description: Acceptance gate and completion - verify the whole system works, clean up, commit with evidence summary
  shortcut: cleanup

  tools:
    safe:
      - read_file
      - glob
      - grep
      - bash
      - delegate
      - recipes
      - LSP
      - python_check
      - load_skill
      - write_file
      - edit_file
      - apply_patch

  default_action: block
  allowed_transitions: [execute, plan, brainstorm]
  allow_clear: true
---

CLEANUP MODE: Acceptance gate → cleanup → commit → done.

**Core principle:** Two steps in sequence. Step 1 cannot be skipped. Step 2 unlocks only after Step 1 passes.

<CRITICAL>
THE ACCEPTANCE GATE IS NOT OPTIONAL.

Step 1 (acceptance gate) MUST pass before Step 2 (cleanup work) begins.
You cannot skip the gate. You cannot "just clean up and commit."
The gate verifies the WHOLE SYSTEM works — not individual tasks (execute already did that).

If the gate fails, classify as RETRY/REPLAN/RETHINK and route back.
</CRITICAL>

## Step 1: Acceptance Gate (CANNOT SKIP)

**Question:** Does the system as a whole deliver on the Theory of Success defined in brainstorm?

This is NOT a re-check of individual tasks — execute already closed those loops. This is a single system-level question: does the whole thing work as intended?

### How to Run the Gate

1. **Find the overall Theory of Success** — it should be in the design document from brainstorm
2. **Run or observe the system as a user would** — not through internal APIs or unit tests, but as an actual user
3. **Evaluate the evidence** against the overall Theory of Success

### Gate Results

**PASS:**
```
Acceptance gate PASSED.

Overall Theory of Success: [state it]
Evidence: [what you observed/ran]
Result: System delivers on the stated outcome.

Proceeding to cleanup.
```
→ Step 2 unlocks.

**FAIL:**
```
Acceptance gate FAILED.

Overall Theory of Success: [state it]
Evidence: [what you observed/ran]
Gap: [specific gap between expected and actual]

Classification: [RETRY / REPLAN / RETHINK]
Reason: [why this classification]
```
→ Route back to the appropriate mode:

| Classification | Route | When |
|---------------|-------|------|
| **RETRY** | `/execute` | System almost works — specific task needs re-execution |
| **REPLAN** | `/plan` | System doesn't deliver because the plan missed something |
| **RETHINK** | `/brainstorm` | System doesn't deliver because the idea itself was wrong |

**Do NOT proceed to Step 2 if the gate fails.** Route back first. Come back to cleanup after the issue is resolved.

## Step 2: Cleanup Work (Only After Gate PASSES)

This step is LOCKED until the acceptance gate passes. Do not begin cleanup work before the gate.

### 2a: Remove Artifacts

Clean up anything that was "working infrastructure" but not the deliverable:
- Temp files, debug logs, experimental scaffolding
- WIP comments, TODO markers that were resolved
- Test fixtures that are no longer needed
- Any files created during development that aren't part of the final deliverable

### 2b: Commit with Evidence Summary

The commit message summarizes what was PROVEN, not what was done:

```bash
# Good: evidence-based commit message
git add -A
git commit -m "feat: [feature name]

Proven:
- [evidence summary from task 1]
- [evidence summary from task 2]
- ...

Acceptance gate: [overall Theory of Success] — PASSED"
```

```bash
# Bad: activity-based commit message
git commit -m "feat: add auth middleware

- Created auth.ts
- Added JWT validation
- Registered middleware
- Updated tests"
```

The evidence summary from execute mode carries into the commit message naturally — you already have all the proof from the convergence loops.

### 2c: Present Completion Options

Present exactly 3 options:

```
Cleanup complete. Committed with evidence summary.

1. LOCAL — Keep as local commit only (already done)
2. PUSH — Push to remote: `git push origin <branch>`
3. PR — Push and create a Pull Request: `git push -u origin <branch> && gh pr create`

Which option?
```

### Executing the Choice

**Option 1: LOCAL**
```
Local commit preserved. Branch: <name>
```
Done. No further action.

**Option 2: PUSH**
```bash
git push origin <branch>
```
Report: "Pushed to origin/<branch>."

**Option 3: PR**
```bash
git push -u origin <branch>
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
[2-3 bullets of what was proven]

## Evidence
[Key evidence from convergence loops]

## Acceptance Gate
[Overall Theory of Success] — PASSED
EOF
)"
```
Report the PR URL.

## Anti-Rationalization Table

| Your Excuse | Why It's Wrong |
|-------------|---------------|
| "Acceptance gate is redundant — execute already verified everything" | Execute verified TASKS. The gate verifies the WHOLE SYSTEM. Different scope. Non-negotiable. |
| "I can tell it works from the task results" | Telling ≠ proving. Run the system as a user would. |
| "The gate will obviously pass" | Then it takes 30 seconds. That's not a reason to skip it. |
| "Let me just clean up first" | Step 2 is LOCKED until Step 1 passes. This is the architecture. |
| "The commit message doesn't need evidence" | The commit message IS the record of what was proven. Activity narration is worthless 6 months later. |

## Do NOT:
- Skip the acceptance gate
- Begin cleanup work before the gate passes
- Write activity-based commit messages
- Force-push without explicit user request
- Delete work without confirmation
- Route back without classifying the failure (RETRY/REPLAN/RETHINK)

## Announcement

When entering this mode, announce:
"I'm entering cleanup mode. Two steps: (1) acceptance gate — does the whole system deliver on the Theory of Success? Cannot skip. (2) Cleanup and commit — only after the gate passes."

## Transitions

**Done when:** Committed/pushed/PR created

**Golden path:** Session complete
- Tell user: "Completed via [chosen option]. Evidence committed."
- Use `mode(operation='clear')` to exit modes.

**Dynamic transitions:**
- If acceptance gate fails with RETRY → use `mode(operation='set', name='execute')` because a specific task needs re-execution
- If acceptance gate fails with REPLAN → use `mode(operation='set', name='plan')` because the plan missed something
- If acceptance gate fails with RETHINK → use `mode(operation='set', name='brainstorm')` because the design needs revision
- If user wants more work on this project → use `mode(operation='set', name='brainstorm')` because new work needs the design process

**Skill connection:** If you load a workflow skill,
the skill tells you WHAT to do. This mode enforces HOW. They complement each other.
```

**Theory of Success:** File exists with valid mode YAML frontmatter (`name: cleanup`, `allow_clear: true`, all write tools in `safe` list), two-step structure with acceptance gate as Step 1 (cannot skip), cleanup work as Step 2 (locked until gate passes), 3 completion options (LOCAL/PUSH/PR), backward routing on gate failure with RETRY/REPLAN/RETHINK.

**Proof:** `head -25 /Users/ken/workspace/ms/flywheel/modes/cleanup.md && grep -E "acceptance gate|CANNOT SKIP|Step 1|Step 2|RETRY|REPLAN|RETHINK|LOCAL|PUSH|PR" /Users/ken/workspace/ms/flywheel/modes/cleanup.md | head -15 && grep -c "superpowers\|finish\|MERGE\|DISCARD\|verify" /Users/ken/workspace/ms/flywheel/modes/cleanup.md`

**NFR scan:**
- YAML frontmatter: `name: cleanup`. `allow_clear: true`. Write tools (`write_file`, `edit_file`, `apply_patch`) in `safe` list (cleanup needs to delete/commit).
- Scope: 3 options (LOCAL/PUSH/PR), not superpowers' 4 (MERGE/PR/KEEP/DISCARD). No worktree management.
- Acceptance gate: Must be clearly marked as non-optional with CRITICAL block.

---

## Task 10: Phase 1 commit and push

**Files:**
- All files created in Tasks 1-9

**What to do:**

```bash
cd /Users/ken/workspace/ms/flywheel
git add bundle.md behaviors/flywheel-methodology.yaml context/philosophy.md context/instructions.md context/using-flywheel.md modes/brainstorm.md modes/plan.md modes/execute.md modes/cleanup.md
git commit -m "feat: flywheel phase 1 — bundle infrastructure, behavior wiring, and 4 modes

Proven:
- bundle.md declares flywheel bundle with 4 modes and 4 agents
- behaviors/flywheel-methodology.yaml wires hooks, tools, agents, and context
- context/ contains philosophy (Theory of Success, Goldilocks), instructions, and usage guide
- modes/ contains brainstorm, plan, execute, cleanup with flywheel-specific content
- All files use @flywheel: namespace, zero superpowers references
- All YAML files parse without errors"
git push origin main
```

**Theory of Success:** `git log --oneline` shows Phase 1 commit. `git status` shows clean working tree. All 9 files tracked.

**Proof:** `cd /Users/ken/workspace/ms/flywheel && git log --oneline -3 && git status && git diff --stat HEAD~1`

**NFR scan:**
- Git hygiene: Single commit for Phase 1. Evidence-based commit message (what was proven, not what was done).
- Remote: Pushed to `kenotron-ms/flywheel` on GitHub.
