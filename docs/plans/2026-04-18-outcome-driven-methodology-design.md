# Outcome-Driven Methodology Bundle Design

## Goal

Replace the superpowers Amplifier bundle with a new methodology bundle built on a different epistemology: close evidence loops, don't complete activities.

## Background

The current superpowers bundle organises work around activity completion — agents do things, reviewers check things, tests confirm things. This works, but it has a structural weakness: activity completion is a proxy for outcomes, and proxies drift. Tests pass while the feature is broken. Code review approves while the design is wrong. Activity narration burns tokens without proving anything.

This bundle replaces that model. Instead of "did you do the thing?", the fundamental question becomes "can you prove the thing works?" Every task defines what done *looks like* before execution starts, and execution isn't complete until evidence closes that loop. The methodology is designed for daily software development use as a complete replacement for the superpowers installation.

## Approach

**Option A — lean modes + agents, no recipes yet.** Validate the methodology through use before automating it with recipes. Like superpowers, modes guide the user to the next mode. Forward progression is deterministic (always left to right); backward routing is free (any failure can escalate directly to the right level without passing through intermediate modes).

This keeps the bundle lightweight and testable. Recipes can be layered on once the mode transitions and agent contracts are proven in practice.

## Detailed Design

### 1. Core Philosophy

Three foundational ideas underpin every decision in the bundle:

**Theory of Success over tests.** Before any task executes, the plan defines two things: what done *looks like* to an observer, and the specific action that *proves* it. Not "write a test that passes" — actual evidence: a curl showing a 401 response, a screenshot showing the UI state, a log line showing the migration ran. Tests can pass and the thing can still be broken. Evidence can't lie the same way.

**Outcome over activity.** Agents report what they *proved*, not what they *did*. No lengthy narration about implementation steps. The implementer shows the proof. The verifier says VERIFIED or NEEDS_MORE_PROOF. Token cost is proportional to results, not effort expended.

**Architect mindset in the plan.** Every task gets a lightweight NFR scan — security, privacy, performance, resource contention, reliability — not as a checklist, but as a prompt: which of these apply here, and what does "good enough" look like for this task? This surfaces concerns at planning time, not in production. 2–3 lines per task, not a threat model.

**The Goldilocks principle** ties all three together: verification effort is calibrated to task complexity. A config change needs `cat config | grep key`. A new API endpoint needs a real curl with response. A UI change needs a screenshot. Not more, not less.

---

### 2. Phase Architecture

Four modes. The forward path is a ratchet (always left to right). Backward routing is free — any failure can escalate directly to the right level without passing through intermediate modes.

```
brainstorm → plan → execute → cleanup
     ↑           ↑      ↑         │
     └───────────┴──────┘         │
       (any failure routes back)  └→ done
```

#### brainstorm

Design the thing. Define what overall success looks like for the whole effort. Write tools blocked for the main agent; the brainstormer agent handles the design doc. Encourages defining the overall Theory of Success for the entire effort during design — not just per-task later.

Guides to: **plan**.

#### plan

Planner agent produces a task list where each task has three parts:

1. **What to build** — superpowers-level implementation detail (file paths, function signatures, patterns to follow)
2. **Theory of Success** — what done looks like + specific proof action
3. **NFR scan** — which concerns apply + what "good enough" means

Write tools blocked for the main agent; planner writes the plan document.

Guides to: **execute**.

#### execute

Main agent orchestrates task by task. Per task: delegate to implementer → implementer returns outcome + evidence → delegate to verifier → loop if needed. Write tools blocked for the main agent; agents do the work. All tasks verified → guides to **cleanup**. Failure classifications route back to the appropriate earlier mode.

No dedicated debug mode — the RETRY/REPLAN/RETHINK classification handles routing. A systematic debugging skill is loadable on demand.

Guides to: **cleanup**.

#### cleanup

Two internal steps enforced in sequence — the mode prevents skipping:

1. **Acceptance gate (cannot skip):** Thin holistic check — does the system as a whole deliver on the Theory of Success from brainstorm? Not per-task (execute already closed those loops) — a single system-level question. Run or observe the system as a user would. If it fails, classify as RETRY/REPLAN/RETHINK and route back to the appropriate mode. If it passes, step 2 unlocks.

2. **Cleanup work (unlocks only after acceptance gate passes):** Remove temp files, debug artifacts, experimental scaffolding. Commit with evidence summary — the message summarises what was proven, not what was done. Three options presented: local commit only, push to remote, or open a PR.

#### Backward Routing — Failure Classification

Every failure (from verifier or acceptance gate) must be classified before routing back:

- **RETRY** — execution issue, re-run the task in execute
- **REPLAN** — the plan's Theory of Success or NFR scan was wrong, back to plan
- **RETHINK** — the idea itself is flawed, back to brainstorm

---

### 3. Agent Roster

Four agents (down from superpowers' six):

#### brainstormer
Carried over from superpowers. Writes the design document after the design has been validated in conversation.

`model_role: reasoning`

#### planner
Replaces superpowers' `plan-writer`. Same job, different output format. Produces tasks with superpowers-level implementation detail PLUS Theory of Success and NFR scan per task. No TDD task lists.

`model_role: reasoning`

#### implementer
Builds the thing AND generates evidence. Runs the exact proof action specified in the plan and returns the raw output. Three status codes:

| Status | Meaning |
|---|---|
| `PROVEN` | Evidence attached |
| `PROVEN_WITH_NOTES` | Done but flagging a concern worth noting |
| `BLOCKED` | Cannot proceed, needs human input |

Does not write a test suite. Evidence is the deliverable.

`model_role: coding`

#### verifier
Replaces both superpowers' `spec-reviewer` and `code-quality-reviewer`. Receives the task definition (Theory of Success + NFR from plan) plus the implementer's evidence. Evaluates using the Goldilocks rubric. Five return codes:

| Verdict | Meaning |
|---|---|
| `VERIFIED` | Evidence satisfies Theory of Success |
| `NEEDS_MORE_PROOF` | Specific gap named |
| `RETRY` | Execution issue, re-run in execute |
| `REPLAN` | Plan was wrong, back to plan mode |
| `RETHINK` | Idea is flawed, escalate to brainstorm |

Evidence evaluator, not a code reviewer. Quality concerns are surfaced in the NFR scan at plan time, not reviewed reactively after implementation — this is why there is no separate code-quality-reviewer.

`model_role: critique`

The acceptance gate in cleanup is handled by the cleanup mode itself — a structured prompt, not a full agent delegation. Thin by design.

---

### 4. Plan Format

Each task in the plan has superpowers-level implementation detail (file paths, function signatures, patterns to follow, naming conventions) PLUS a Theory of Success and NFR scan at the end.

**Structure per task:**

```
## Task N: [Title]

Context: [relevant files, existing patterns to follow]

What to build:
- [specific implementation steps with file paths, function signatures, etc.]
- [same level of detail as superpowers plan-writer produces]

Theory of Success: [what done looks like to an observer].
Proof: [specific runnable action — curl, screenshot, query, log grep — that proves it]

NFR scan:
- [concern]: [what "good enough" looks like for this task]
- [concern]: [what "good enough" looks like for this task]
```

**Example:**

```
## Task 3: Add JWT auth middleware

Context: Existing routes in src/api/routes/*.ts. Middleware in src/api/middleware/.
Follow pattern in src/api/middleware/logging.ts.

What to build:
- Create src/api/middleware/auth.ts — validateJWT(token: string): JWTPayload | null
- Register middleware in src/api/server.ts before route mounting, apply to /api/* only
- Use existing jwtSecret from src/config.ts (already exported)
- Return { status: 401, body: { error: "unauthorized" } } on missing/invalid token
- On valid token, attach decoded payload to req.user

Theory of Success: Unauthenticated request to /api/users returns 401 with
{"error":"unauthorized"}. Authenticated request with valid token returns 200 + data.
Proof: run both curls and show actual response bodies.

NFR scan:
- Security: validate signature, not just decode. Check expiry. Reject tampered tokens.
- Performance: no DB call per request — validation is stateless.
- Privacy: no PII in token payload or logs.
```

---

### 5. Execution Loop

Inside execute mode, each task follows a convergence loop:

```
┌─────────────────────────────────────────────────┐
│  1. Delegate to implementer with full task       │
│  2. Implementer builds + runs proof action       │
│  3. Implementer returns status + raw evidence    │
│  4. Delegate to verifier with task def + evidence│
│  5. Verifier evaluates against Theory of Success │
│                                                  │
│  Verdict routing:                                │
│    VERIFIED          → next task                 │
│    NEEDS_MORE_PROOF  → back to implementer (gap) │
│    RETRY             → re-run task from scratch  │
│    REPLAN            → exit to plan mode         │
│    RETHINK           → exit to brainstorm mode   │
└─────────────────────────────────────────────────┘
```

**Token discipline:** Agents return outcomes, not narration. The implementer shows the evidence, not the story of how it was built. The verifier names the verdict and specific gap (if any). Short, evidential, done.

**Goldilocks rubric** (lives inside verifier agent instructions):

| Task type | Minimum proof | Sufficient | Over-verification |
|---|---|---|---|
| UI change | Screenshot of affected state | Screenshot + interaction if interactive | Full automation suite |
| API endpoint | Single curl with status | Request + response headers + body | Load test |
| DB migration | Row count or schema query | Count + schema describe | Full integrity check |
| Config change | grep of changed key | Output + behaviour diff | Unit test of config parsing |
| Refactor | Existing tests still pass | Test output + diff summary | Re-implementation |
| Script/automation | Script output with expected values | Output + input→output traceability | Coverage report |

---

### 6. Cleanup Phase

Cleanup enforces two steps in sequence — the mode prevents skipping.

**Step 1 — Acceptance gate (cannot skip):**

Holistic check: does the system as a whole deliver on the Theory of Success from brainstorm? Not per-task (execute already closed those loops) — a single system-level question. Run or observe the system as a user would.

- Pass → step 2 unlocks
- Fail → classify as RETRY / REPLAN / RETHINK and route back to the appropriate mode

**Step 2 — Cleanup work (unlocks only after acceptance gate passes):**

- Remove temp files, debug artifacts, experimental scaffolding
- Commit — message summarises what was proven, not what was done (evidence summary from execute is already available)
- Three options presented: **local commit only**, **push to remote**, or **open a PR**

## Open Questions

- **Bundle name.** Not yet decided. Should reflect the "Theory of Success" / "outcome-driven" / "close the loop" philosophy.
- **Where it lives.** Personal replacement for superpowers. Bundle location TBD — could be a personal workspace bundle or standalone repo.
- **Existing brainstorm carry-over.** The brainstorm mode and brainstormer agent are carried over almost unchanged from superpowers. The main addition: encourage defining the overall Theory of Success for the whole effort during design, not just per-task later.
- **Skills.** No skills defined yet. Candidates: a verification rubric skill (expanded Goldilocks table), an NFR scan cheatsheet skill, a debugging skill (loadable on demand in execute mode).
