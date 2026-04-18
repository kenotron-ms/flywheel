# Flywheel Phase 2: Agents, Skills, Claude Code Plugin + Deploy

> **For execution:** Use subagent-driven-development workflow to implement this plan.

**Goal:** Create the 4 agents, 2 skills, Claude Code plugin, shadow test infrastructure, and deploy to GitHub.

**Architecture:** Agents replace superpowers equivalents with Theory of Success focus. `verifier` is entirely new (Goldilocks rubric evaluator). Claude Code plugin adapts the methodology as portable skills. Shadow tests validate bundle structure without any LLM invocation.

**No TDD.** Tasks create Markdown/YAML files. Verification uses Theory of Success format: observable outcome + proof action + NFR scan. No RED/GREEN/REFACTOR cycles anywhere in this plan.

**Prerequisite:** Phase 1 must be complete (bundle.md, behaviors/flywheel-methodology.yaml, context/philosophy.md, context/instructions.md, modes/brainstorm.md, modes/plan.md, modes/execute.md, modes/cleanup.md all exist).

---

## Task 1: agents/brainstormer.md

Context: The superpowers brainstormer agent lives at `~/.amplifier/cache/amplifier-bundle-superpowers-*/agents/brainstormer.md`. It has a `meta:` frontmatter block with name, description, model_role, and a `tools:` block listing modules with `git+https://` sources. The flywheel brainstormer is nearly identical — the only changes are namespace (`@flywheel:` instead of `@superpowers:`), mode transition target (`plan` instead of `write-plan`), and the addition of "Theory of Success" language encouraging users to define what overall success looks like during design.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/agents/brainstormer.md`

What to build:

Frontmatter (YAML between `---` fences):
```yaml
meta:
  name: brainstormer
  description: |
    Use after brainstorm-mode conversation to write the validated design as a formal document

    Examples:
    <example>
    Context: Design validated through brainstorm-mode conversation
    user: "The design looks good, let's document it"
    assistant: "I'll delegate to flywheel:brainstormer to write the design document."
    <commentary>Brainstormer writes the artifact after design is validated with user.</commentary>
    </example>

    <example>
    Context: All design sections approved by user in brainstorm mode
    user: "Save this design"
    assistant: "I'll use flywheel:brainstormer to format and save the design document."
    <commentary>Document creation is the brainstormer agent's sole responsibility.</commentary>
    </example>

  model_role: [reasoning, general]
tools:
  - module: tool-filesystem
    source: git+https://github.com/microsoft/amplifier-module-tool-filesystem@main
  - module: tool-bash
    source: git+https://github.com/microsoft/amplifier-module-tool-bash@main
```

Body (after closing `---`):
- Title: `# Design Document Writer`
- Role description: receives a complete, user-validated design in delegation instruction. Structures it into a clean design doc, writes it to `docs/plans/YYYY-MM-DD-<topic>-design.md`, commits.
- Design document template with sections: Goal, Background, Approach, Architecture, Components, Data Flow, Error Handling, Open Questions.
- **Key addition vs superpowers:** Add a "Theory of Success" section to the template: encourage the brainstormer to include an overall Theory of Success for the effort — what done looks like at the system level — which the planner will decompose into per-task Theories of Success later.
- Red Flags section: same as superpowers (adding content not in the validated design, asking questions, skipping sections, not committing, inventing requirements).
- Context reference at the bottom: `@flywheel:context/philosophy.md` (NOT `@superpowers:context/philosophy.md`).
- Do NOT reference any `@foundation:` or `@superpowers:` resources. Only `@flywheel:`.

Theory of Success: File exists at `/Users/ken/workspace/ms/flywheel/agents/brainstormer.md` with valid meta frontmatter containing `name: brainstormer`, `model_role: [reasoning, general]`, references `@flywheel:` (not `@superpowers:`), mentions "Theory of Success" in the template, and transitions toward plan mode.

Proof:
```bash
grep -E "brainstormer|reasoning|plan|Theory of Success|@flywheel:" /Users/ken/workspace/ms/flywheel/agents/brainstormer.md
```

NFR scan:
- Namespace safety: Zero `@superpowers:` references. Grep the file for `@superpowers:` — must return nothing.
- Compatibility: Frontmatter must parse as valid YAML. The `tools:` block lists modules with `git+https://` sources matching the pattern in superpowers agents.

---

## Task 2: agents/planner.md (KEY AGENT — replaces plan-writer)

Context: The superpowers plan-writer lives at `~/.amplifier/cache/amplifier-bundle-superpowers-*/agents/plan-writer.md`. The flywheel planner has the **same meta frontmatter structure** but **significantly rewritten body**. The plan-writer produces TDD task lists; the planner produces Theory of Success task lists. This is the philosophical heart of flywheel's differentiation from superpowers. Additionally, the planner includes `tool-bash` in its tools list (the superpowers plan-writer does not) and adds `tool-search`.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/agents/planner.md`

What to build:

Frontmatter:
```yaml
meta:
  name: planner
  description: |
    Use after plan-mode conversation to format the validated plan as a formal document

    Examples:
    <example>
    Context: Plan structure discussed and agreed in plan mode
    user: "Create the implementation plan"
    assistant: "I'll delegate to flywheel:planner to write the detailed implementation plan."
    <commentary>Planner formats and writes the plan after task breakdown is agreed.</commentary>
    </example>

    <example>
    Context: Design exists, plan discussion complete
    user: "Write out the tasks we discussed"
    assistant: "I'll use flywheel:planner to create the implementation plan with Theory of Success per task."
    <commentary>Turning validated discussions into detailed plans is the planner's sole responsibility.</commentary>
    </example>

  model_role: [reasoning, general]
tools:
  - module: tool-filesystem
    source: git+https://github.com/microsoft/amplifier-module-tool-filesystem@main
  - module: tool-bash
    source: git+https://github.com/microsoft/amplifier-module-tool-bash@main
  - module: tool-search
    source: git+https://github.com/microsoft/amplifier-module-tool-search@main
```

Body — the full agent instructions. Write these sections in this exact order:

**1. Title:** `# Implementation Planner`

**2. Role:** "You create implementation plans where every task has a Theory of Success — an observable outcome with a specific proof action. You produce superpowers-level implementation detail (exact file paths, function signatures, naming conventions, patterns to follow) PLUS evidence-based verification per task."

**3. Your Audience:** Same as superpowers plan-writer:
- Skilled at coding but knows nothing about this codebase
- Doesn't know the toolset or problem domain
- Will follow instructions literally
- Needs explicit, bite-sized steps

**4. Before Writing:** Mandatory codebase exploration:
1. READ the design document referenced in the delegation instruction — fail with clear error if not found
2. SEARCH for existing patterns — use grep/glob to find naming conventions, directory structure
3. VERIFY file paths — confirm directories exist and paths in the plan will be correct
4. NOTE imports and dependencies — understand what's already available

**5. Plan Header (Required):**
```markdown
# [Feature Name] Implementation Plan

> **For execution:** Use /mode execute or subagent-driven-development.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences about approach]
**No TDD.** [If applicable — state verification approach]

---
```

**6. Task Structure — the core innovation.** Each task contains:
```markdown
### Task N: [Title]

Context: [relevant files, existing patterns to follow, what prior tasks built]

What to build:
- [specific — file paths, function signatures, naming conventions]
- [same level of detail superpowers plan-writer produces]
- [exact commands, exact code, exact paths]

Theory of Success: [what done looks like to an observer — the outcome, not the activity]
Proof: [specific runnable action — curl, grep, screenshot, query — that proves it]

NFR scan:
- [concern]: [what "good enough" means for this task]
- [concern]: [what "good enough" means for this task]
```

**7. Anti-TDD declaration (embed verbatim):**
```
## What This Plan Does NOT Contain

NO TDD steps. No RED/GREEN/REFACTOR. No "write failing test first."

Instead, each task ends with a Theory of Success — an observable outcome — and a Proof
action — a specific command that demonstrates the outcome. Evidence over tests.

If the implementer's instinct says "TDD would be clearer": the Theory of Success IS
clearer. Write the evidence, not the test.
```

**8. Plan Size rule:** Plans >15 tasks must be split into phases. Each phase gets its own plan document.

**9. Granularity Rules:** Each task should be 2-5 minutes of work. Not "set up the module" (too vague) or "handle edge cases" (too vague). Specific, concrete, one thing per task.

**10. Content Rules:**
- Exact file paths. Always. No "somewhere in src/".
- Complete code when showing code. Not "add validation" — show the actual code.
- Exact commands. With expected output.

**11. Save Location:** `docs/plans/YYYY-MM-DD-<feature-name>-plan.md`

**12. Completion:** After saving, announce: "Plan saved to [path]. Ready for /mode execute."

**13. Context references at bottom:**
```
@flywheel:context/philosophy.md
```

Theory of Success: File exists at `/Users/ken/workspace/ms/flywheel/agents/planner.md` with valid meta frontmatter containing `name: planner`, `model_role: [reasoning, general]`, explicitly mentions "NO TDD" and "Theory of Success" in the body, shows the task format template with Theory of Success / Proof / NFR scan sections, and references only `@flywheel:`.

Proof:
```bash
grep -E "planner|Theory of Success|NO TDD|Proof:|NFR scan|@flywheel:" /Users/ken/workspace/ms/flywheel/agents/planner.md
```

NFR scan:
- Namespace safety: Zero `@superpowers:` references.
- Clarity: The anti-TDD section must be unambiguous — an implementer reading this plan format cannot interpret it as requiring tests.
- Completeness: The task format template must include all three parts (What to build, Theory of Success + Proof, NFR scan).

---

## Task 3: agents/implementer.md

Context: The superpowers implementer lives at `~/.amplifier/cache/amplifier-bundle-superpowers-*/agents/implementer.md`. It follows TDD (RED/GREEN/REFACTOR). The flywheel implementer **discards TDD entirely** and instead follows the Theory of Success loop: read task → implement → run proof action → return evidence. The three return status codes (PROVEN, PROVEN_WITH_NOTES, BLOCKED) are the implementer's entire output contract. No tool-python-check needed (this is a methodology bundle, not a Python dev bundle).

Files:
- Create: `/Users/ken/workspace/ms/flywheel/agents/implementer.md`

What to build:

Frontmatter:
```yaml
meta:
  name: implementer
  description: |
    Use when executing a single task from an implementation plan

    Examples:
    <example>
    Context: Executing a task from a flywheel implementation plan
    user: "Implement Task 3: Add JWT auth middleware"
    assistant: "I'll delegate to flywheel:implementer with the full task specification."
    <commentary>Single task from a plan — runs the proof action and returns evidence.</commentary>
    </example>

    <example>
    Context: Task has a Theory of Success and proof action
    user: "Build the verifier agent file"
    assistant: "I'll use flywheel:implementer to build it and run the proof."
    <commentary>Implementer builds AND proves — evidence is the deliverable.</commentary>
    </example>

  model_role: [coding, general]
tools:
  - module: tool-filesystem
    source: git+https://github.com/microsoft/amplifier-module-tool-filesystem@main
  - module: tool-bash
    source: git+https://github.com/microsoft/amplifier-module-tool-bash@main
  - module: tool-search
    source: git+https://github.com/microsoft/amplifier-module-tool-search@main
```

Body — write these sections:

**1. Title:** `# Task Implementer`

**2. Role:** "You implement a single task from an implementation plan. You build the thing, run the proof action, and return evidence. Evidence is your deliverable — not the code, not the explanation."

**3. Your Process — in exact order:**

```markdown
### 1. Understand the Task
- Read the full task specification: What to build + Theory of Success + NFR constraints
- Identify files to create/modify
- Note the proof action you'll run at the end
- If ANYTHING is unclear, return BLOCKED immediately — don't guess

### 2. Implement
- Build what the task specifies — nothing more, nothing less
- Follow NFR constraints DURING implementation (not as afterthoughts)
- Follow existing patterns and naming conventions noted in the task's Context section
- No extra features, no "while I'm here" improvements

### 3. Run the Proof Action
- Run the EXACT proof action specified in the task plan — verbatim
- Capture the raw output
- Do NOT run additional verifications beyond the specified proof action
- Do NOT add tests unless tests ARE the specified proof action

### 4. Return Your Status
Return EXACTLY one of these three formats. Nothing else.
```

**4. Status Codes — embed verbatim:**

````markdown
## Status Codes

### When the proof action succeeds:
```
PROVEN
[raw evidence: actual output of proof action — paste it verbatim, nothing else]
```

### When the proof action succeeds but you spotted a concern:
```
PROVEN_WITH_NOTES
[raw evidence: actual output of proof action]
Note: [specific concern worth flagging — one sentence, brief]
```

### When you cannot proceed:
```
BLOCKED
Need: [exact input or clarification required before proceeding — be specific]
```
````

**5. Iron Laws:**

```markdown
## Iron Laws

**Evidence is the deliverable.** Not the code, not a narration of what you did.

**No narration.** Do not explain your implementation process. Do not describe what
you built. The evidence speaks for itself.

**No extra verification.** Do not run tests, linters, or checks beyond the specified
proof action. The verifier evaluates sufficiency — that's not your job.

**No scope creep.** Implement what the task says. If you see something else that
needs fixing, note it in PROVEN_WITH_NOTES. Don't fix it.

**BLOCKED is not failure.** If the task is ambiguous, missing info, or depends on
something that doesn't exist yet — return BLOCKED immediately. Don't guess.
```

**6. Scope Boundary:**
"You are a task executor. Your scope is limited to the task you've been given. Do NOT run git push, git merge, gh pr create, or any deployment commands. Committing your work is the final step — integration and release are handled by a later stage."

**7. Context reference at bottom:** `@flywheel:context/philosophy.md`

Theory of Success: File exists at `/Users/ken/workspace/ms/flywheel/agents/implementer.md` with valid meta frontmatter containing `name: implementer`, `model_role: [coding, general]`, all three status codes (PROVEN, PROVEN_WITH_NOTES, BLOCKED) present in the body, no TDD/RED/GREEN/REFACTOR language anywhere.

Proof:
```bash
grep -E "implementer|PROVEN|PROVEN_WITH_NOTES|BLOCKED|coding" /Users/ken/workspace/ms/flywheel/agents/implementer.md && echo "---" && ! grep -E "RED.*GREEN|GREEN.*REFACTOR|TDD|failing test" /Users/ken/workspace/ms/flywheel/agents/implementer.md && echo "NO TDD REFERENCES: PASS"
```

NFR scan:
- Token discipline: The iron laws section must enforce brevity — agents should not narrate.
- Namespace safety: Zero `@superpowers:` references. No `@foundation:` references.
- Clarity: The three status codes must be unambiguous and their formats must be copy-pasteable.

---

## Task 4: agents/verifier.md (NEW — no superpowers equivalent)

Context: This agent has NO superpowers equivalent. It replaces both `spec-reviewer` and `code-quality-reviewer` with a single evidence evaluator. The verifier receives: (1) the task definition from the plan (Theory of Success + NFR scan), and (2) the implementer's evidence. It evaluates whether the evidence satisfies the Theory of Success using the Goldilocks rubric — not too little proof, not too much, just right. Five verdict codes.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/agents/verifier.md`

What to build:

Frontmatter:
```yaml
meta:
  name: verifier
  description: |
    Use after implementer returns evidence to evaluate it against the Theory of Success

    Examples:
    <example>
    Context: Implementer returned PROVEN with evidence
    user: "Verify Task 3 evidence against the plan"
    assistant: "I'll delegate to flywheel:verifier to evaluate the evidence."
    <commentary>Verifier evaluates evidence quality — not code quality.</commentary>
    </example>

    <example>
    Context: Implementer returned PROVEN_WITH_NOTES with a concern
    user: "Check if this evidence is sufficient"
    assistant: "I'll use flywheel:verifier to apply the Goldilocks rubric."
    <commentary>Evidence evaluator, not code reviewer. Uses calibrated rubric.</commentary>
    </example>

  model_role: [critique, reasoning, general]
tools:
  - module: tool-filesystem
    source: git+https://github.com/microsoft/amplifier-module-tool-filesystem@main
  - module: tool-bash
    source: git+https://github.com/microsoft/amplifier-module-tool-bash@main
```

Body — write these sections:

**1. Title:** `# Evidence Verifier`

**2. Role:** "You evaluate implementer evidence against the Theory of Success defined in the plan. You are an evidence evaluator, not a code reviewer. Quality concerns were surfaced at plan time in the NFR scan — your job is to determine whether the proof action's output actually proves what the Theory of Success claims."

**3. Your Process:**

```markdown
### 1. Read the Task Definition
From the plan, extract:
- **Theory of Success:** What done looks like
- **Proof action:** What command/action should have been run
- **NFR scan:** What constraints applied

### 2. Read the Implementer's Evidence
From the implementer's response, extract:
- **Status:** PROVEN, PROVEN_WITH_NOTES, or BLOCKED
- **Raw evidence:** The actual output of the proof action
- **Notes:** Any concerns flagged (if PROVEN_WITH_NOTES)

### 3. Evaluate Using the Goldilocks Rubric
Ask these questions:
1. Did the implementer run the specified proof action (not a substitute)?
2. Does the evidence output match what the Theory of Success predicted?
3. Is this enough evidence per the rubric below — or too little? Or too much was demanded?
4. Do the NFR constraints appear to be respected (based on evidence, not code review)?

### 4. Return Your Verdict
Return EXACTLY one verdict. Nothing else.
```

**4. Verdict Codes — embed verbatim:**

````markdown
## Verdict Codes

### Evidence satisfies Theory of Success:
```
VERIFIED
```

### Evidence is close but has a specific gap:
```
NEEDS_MORE_PROOF
Gap: [exactly what's missing — specific, actionable, one sentence]
```

### Implementation produced wrong/broken/missing output:
```
RETRY
Reason: [what went wrong — specific]
```

### Theory of Success in the plan is wrong, ambiguous, or impossible to prove:
```
REPLAN
Reason: [what's wrong with the plan — specific]
```

### Underlying design assumption is invalid:
```
RETHINK
Reason: [what design assumption failed — specific]
```
````

**5. The Goldilocks Rubric — embed this table verbatim:**

```markdown
## The Goldilocks Rubric

Verification effort must be calibrated to task complexity. Use this table to
determine whether evidence is sufficient. Do NOT demand more than "Sufficient."
Do NOT accept less than "Minimum."

| Task type | Minimum proof | Sufficient | Over-verification (do NOT demand) |
|---|---|---|---|
| UI change | Screenshot of affected state | Screenshot + interaction proof if interactive | Full automation suite |
| API endpoint | Single curl with status code | Request + response headers + body | Load test |
| DB migration | Row count or schema query | Count + schema describe | Full integrity check |
| Config change | grep of changed key | Output + behaviour diff | Unit test of config parsing |
| Refactor | Existing tests still pass | Test output + diff summary | Re-implementation |
| Script/automation | Script output with expected values | Output + input→output traceability | Coverage report |
| File creation | File exists with required content | Content grep + structural validity check | Manual line-by-line review |

### How to use this table:
1. Identify the task type from the left column
2. Check if the evidence meets at least "Minimum proof"
3. If it meets "Sufficient" — return VERIFIED, stop
4. If it's between Minimum and Sufficient — return VERIFIED (it's good enough)
5. If it's below Minimum — return NEEDS_MORE_PROOF with the specific gap
6. NEVER demand evidence at the "Over-verification" level
```

**6. Failure Classification Guidance:**

```markdown
## When to Use Each Non-VERIFIED Verdict

**NEEDS_MORE_PROOF** — the implementation probably works, but the evidence doesn't
prove it yet. The gap is in the EVIDENCE, not the code.
Example: Task says "curl returns 401" but evidence only shows the curl command, not
the response.

**RETRY** — the implementation clearly failed. Wrong output, crash, missing file,
error in evidence.
Example: Evidence shows a stack trace or "file not found" or wrong status code.

**REPLAN** — the Theory of Success itself is wrong. It asks to prove something that
can't be proven this way, or the proof action is invalid.
Example: Theory says "API returns user list" but the API doesn't exist yet (missed
dependency in plan).

**RETHINK** — the underlying design assumption is broken. This isn't a plan issue,
it's a design issue.
Example: The design assumed a library exists that doesn't, or the architecture
can't support the required behaviour.
```

**7. Token Discipline:**

```markdown
## Token Discipline

Your entire response is ONE verdict code + optional one-sentence reason.

Bad: "I reviewed the evidence carefully and found that the implementer successfully
created the file with the correct content. The grep output shows all required
sections are present. I'm satisfied that this meets the Theory of Success. VERIFIED"

Good: "VERIFIED"

Bad: "The evidence is mostly good but I noticed that while the file exists, the
grep only matched 3 of the 5 required patterns. I think we need to check the
remaining patterns to be thorough."

Good: "NEEDS_MORE_PROOF\nGap: grep matched 3/5 required patterns — missing
'acceptance gate' and 'REPLAN' in cleanup mode"
```

**8. Context reference at bottom:** `@flywheel:context/philosophy.md`

Theory of Success: File exists at `/Users/ken/workspace/ms/flywheel/agents/verifier.md` with valid meta frontmatter containing `name: verifier`, `model_role: [critique, reasoning, general]`, the Goldilocks rubric table embedded in the body, all 5 verdict codes (VERIFIED, NEEDS_MORE_PROOF, RETRY, REPLAN, RETHINK) present, and the failure classification guidance.

Proof:
```bash
grep -E "verifier|VERIFIED|NEEDS_MORE_PROOF|RETRY|REPLAN|RETHINK|Goldilocks|critique" /Users/ken/workspace/ms/flywheel/agents/verifier.md
```

NFR scan:
- Token discipline: The verifier's own instructions must enforce brevity — a verifier that narrates defeats the purpose.
- Completeness: All 7 task types in the Goldilocks table must be present. All 5 verdict codes must have clear format examples.
- Namespace safety: Zero `@superpowers:` references. Only `@flywheel:`.

---

## Task 5: skills/verification-rubric/SKILL.md + skills/nfr-scan/SKILL.md

Context: Amplifier skills use a simple frontmatter format with `name:` and `description:` fields (not nested under `meta:`). Reference format from any existing skill: `---\nname: skill-name\ndescription: When to use...\n---\n\n# Skill Title\n...body...`. The flywheel project already has empty directories at `skills/verification-rubric/` and `skills/nfr-scan/`.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/skills/verification-rubric/SKILL.md`
- Create: `/Users/ken/workspace/ms/flywheel/skills/nfr-scan/SKILL.md`

What to build:

**File 1: `skills/verification-rubric/SKILL.md`**

Frontmatter:
```yaml
name: verification-rubric
description: Use when evaluating evidence quality — calibrate verification effort to task complexity using the Goldilocks rubric. Triggers include "is this enough proof", "how much evidence do I need", "verify this", "evaluate evidence", "Goldilocks".
```

Body content:
- Title: `# Goldilocks Verification Rubric`
- Overview: "Every task has a Theory of Success. The rubric calibrates how much evidence is needed to close the loop — not too little (under-verification), not too much (over-verification), just right."
- The core Goldilocks table (same 7-row table as in verifier agent — UI change, API endpoint, DB migration, Config change, Refactor, Script/automation, File creation — with Minimum, Sufficient, Over-verification columns)
- **Expanded guidance per task type** — for each of the 7 task types, provide 2-3 sentences explaining what "good enough" looks like, with a concrete example of minimum proof, sufficient proof, and over-verification:
  - UI change: "Minimum: a screenshot showing the affected component in the expected state. Sufficient: screenshot + a second screenshot or recording showing interaction (click, hover, scroll). Over: setting up Playwright/Cypress for a one-time visual check."
  - API endpoint: "Minimum: `curl -s URL | head` showing the status code. Sufficient: full curl with `-v` showing request, response headers, and body. Over: setting up a load test or writing an integration test suite."
  - DB migration: "Minimum: `SELECT COUNT(*) FROM table` or `\d table` showing the new column. Sufficient: count + full schema describe + a sample row. Over: running a full data integrity check or writing migration rollback tests."
  - Config change: "Minimum: `grep 'key' config.yaml` showing the changed value. Sufficient: grep + running the system and showing the behaviour changed. Over: writing a unit test for config file parsing."
  - Refactor: "Minimum: existing test suite passes (show output). Sufficient: test output + a brief diff summary showing what changed. Over: re-implementing the feature from scratch to verify."
  - Script/automation: "Minimum: run the script, show output contains expected values. Sufficient: run with known input, show input→output traceability. Over: writing a coverage report or test harness for the script."
  - File creation: "Minimum: `ls -la file` + `head file` showing it exists with content. Sufficient: targeted grep for required content + structural check (valid YAML, valid JSON, etc.). Over: line-by-line manual review of every line."
- Calibration principle: "When in doubt, aim for Sufficient. If you're debating between Sufficient and Over — stop at Sufficient. The goal is confidence, not certainty."

**File 2: `skills/nfr-scan/SKILL.md`**

Frontmatter:
```yaml
name: nfr-scan
description: Use when planning tasks to surface non-functional concerns early — security, privacy, performance, resource contention, reliability. Triggers include "NFR", "non-functional", "security scan", "privacy check", "performance concern", "plan a task".
```

Body content:
- Title: `# Lightweight NFR Scan`
- Overview: "Every task in a flywheel plan gets a lightweight NFR scan — 2-3 lines identifying which non-functional concerns apply and what 'good enough' means. This surfaces concerns at planning time, not in production."
- The 5 concern types, each with:
  - **Security:** Questions: Does this handle user input? Does it touch auth/authz? Does it expose new attack surface? "Good enough" heuristic: validate input, use parameterized queries, don't log secrets. Example: "Security: validate JWT signature, not just decode. Check expiry."
  - **Privacy:** Questions: Does this handle PII? Does it create new data flows? Could it log sensitive data? "Good enough" heuristic: no PII in logs, no PII in error messages, minimal data collection. Example: "Privacy: no PII in token payload or logs."
  - **Performance:** Questions: Is this on a hot path? Could it cause N+1 queries? Does it involve large data sets? "Good enough" heuristic: no DB call per request if avoidable, pagination for lists, caching where obvious. Example: "Performance: no DB call per request — validation is stateless."
  - **Resource contention:** Questions: Does this acquire locks? Does it write to shared state? Could concurrent requests conflict? "Good enough" heuristic: use atomic operations, avoid long-held locks, consider retry logic. Example: "Resource: file writes use atomic rename to prevent partial writes."
  - **Reliability:** Questions: What happens when this fails? Is there a fallback? Is it idempotent? "Good enough" heuristic: graceful degradation, meaningful error messages, idempotent where possible. Example: "Reliability: retry with backoff on transient network errors."
- Footer: "Not every concern applies to every task. A file creation task rarely has performance concerns. A config change rarely has privacy concerns. Include only what's relevant — the scan is 2-3 lines, not a threat model."

Theory of Success: Both SKILL.md files exist with valid frontmatter containing `name:` and `description:` fields. The verification-rubric skill contains the Goldilocks table with all 7 task types. The nfr-scan skill contains all 5 concern types.

Proof:
```bash
ls /Users/ken/workspace/ms/flywheel/skills/*/SKILL.md && grep -l "name:" /Users/ken/workspace/ms/flywheel/skills/*/SKILL.md && echo "---" && grep -c "Task type\|UI change\|API endpoint\|DB migration\|Config change\|Refactor\|Script.automation\|File creation" /Users/ken/workspace/ms/flywheel/skills/verification-rubric/SKILL.md && echo "---" && grep -c "Security\|Privacy\|Performance\|Resource\|Reliability" /Users/ken/workspace/ms/flywheel/skills/nfr-scan/SKILL.md
```

NFR scan:
- Discoverability: Both skill descriptions must contain trigger words that match how users would search for them.
- Completeness: All 7 task types in rubric, all 5 concern types in NFR scan. Missing any means the skill is incomplete.

---

## Task 6: Claude Code plugin (claude-code/ directory)

Context: The Claude Code plugin makes flywheel usable outside Amplifier — in vanilla Claude Code. It consists of a CLAUDE.md file (project instructions) and skill files (one per phase). The flywheel project already has an empty `claude-code/skills/` directory. Claude Code skills use the same Agent Skills frontmatter format as Amplifier skills (`name:` and `description:` at top level). CLAUDE.md has no frontmatter — it's plain markdown that Claude Code reads as project context.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/claude-code/CLAUDE.md`
- Create: `/Users/ken/workspace/ms/flywheel/claude-code/skills/brainstorm.md`
- Create: `/Users/ken/workspace/ms/flywheel/claude-code/skills/plan.md`
- Create: `/Users/ken/workspace/ms/flywheel/claude-code/skills/execute.md`
- Create: `/Users/ken/workspace/ms/flywheel/claude-code/skills/cleanup.md`

What to build:

**CLAUDE.md** — project-level instructions for Claude Code:

```markdown
# Flywheel: Outcome-Driven Development

Flywheel is a development methodology that replaces activity completion with evidence loops.
Instead of "did you do the thing?", the question is "can you prove the thing works?"

## The 4 Phases

1. **Brainstorm** — Design the thing. Define what overall success looks like.
2. **Plan** — Break into tasks. Each task gets a Theory of Success + proof action + NFR scan.
3. **Execute** — Build each task. Run the proof. Return evidence. Verify with Goldilocks rubric.
4. **Cleanup** — Acceptance gate (system-level proof). Then cleanup + commit.

## How to Use

Start with brainstorm. Progress forward: brainstorm → plan → execute → cleanup.
Any failure routes backward: RETRY (re-run task), REPLAN (fix the plan), RETHINK (fix the design).

## Skills

Load a phase skill for detailed guidance:
- `brainstorm.md` — Design phase with Theory of Success emphasis
- `plan.md` — Planning with Theory of Success per task (NO TDD)
- `execute.md` — Convergence loop with implementer → verifier pipeline
- `cleanup.md` — Acceptance gate + cleanup work

## Core Principles

- **Theory of Success over tests** — Define what done looks like, then prove it
- **Outcome over activity** — Report what you proved, not what you did
- **Goldilocks verification** — Not too little proof, not too much, just right
- **NFR mindset** — Surface security/privacy/performance concerns at plan time
```

**brainstorm.md** skill:

Frontmatter:
```yaml
name: flywheel-brainstorm
description: Use when starting a new feature or design — guides collaborative design with Theory of Success emphasis. Triggers include "brainstorm", "design", "new feature", "let's think about".
```

Body: Brainstorm phase guidance:
- Role: facilitate design through collaborative dialogue
- Process: understand context → ask questions → propose approaches → present design sections → get validation
- Key addition: encourage defining the overall Theory of Success for the effort during design
- Output: design document saved to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Transition: when design is validated, move to plan phase

**plan.md** skill:

Frontmatter:
```yaml
name: flywheel-plan
description: Use when creating an implementation plan — Theory of Success per task, superpowers-level detail, NO TDD. Triggers include "plan", "create tasks", "break this down", "implementation plan".
```

Body: Plan phase guidance:
- Role: create implementation plans where every task has Theory of Success
- Task format: Context + What to build + Theory of Success + Proof + NFR scan
- **Explicit NO TDD declaration** — no RED/GREEN/REFACTOR, no "write failing test first"
- Plan size: >15 tasks → split into phases
- Output: plan saved to `docs/plans/YYYY-MM-DD-<feature>-plan.md`
- Transition: when plan is complete, move to execute phase

**execute.md** skill:

Frontmatter:
```yaml
name: flywheel-execute
description: Use when executing a plan — convergence loop per task with implementer and verifier roles. Triggers include "execute", "implement the plan", "start building", "run the plan".
```

Body: Execute phase guidance:
- Role: orchestrate task-by-task execution
- Per-task loop: implement → run proof → evaluate evidence → verdict
- Implementer returns: PROVEN / PROVEN_WITH_NOTES / BLOCKED
- Verifier returns: VERIFIED / NEEDS_MORE_PROOF / RETRY / REPLAN / RETHINK
- Verdict routing: VERIFIED → next task, NEEDS_MORE_PROOF → back to implementer, RETRY → re-run, REPLAN → back to plan, RETHINK → back to brainstorm
- Goldilocks rubric summary (condensed version of the table)
- Token discipline: return outcomes, not narration

**cleanup.md** skill:

Frontmatter:
```yaml
name: flywheel-cleanup
description: Use when all tasks are executed — acceptance gate then cleanup work. Triggers include "cleanup", "finish", "wrap up", "acceptance gate", "are we done".
```

Body: Cleanup phase guidance:
- Two steps enforced in sequence — cannot skip step 1
- Step 1: Acceptance gate — does the system as a whole deliver on the Theory of Success from brainstorm? Not per-task (execute closed those loops). A single system-level question. Run or observe as a user would.
  - Pass → step 2 unlocks
  - Fail → classify as RETRY / REPLAN / RETHINK and route back
- Step 2: Cleanup work — remove temp files, debug artifacts, experimental scaffolding. Commit with evidence summary. Three options: local commit only, push to remote, or open a PR.

Theory of Success: CLAUDE.md exists with the 4-phase overview. All 4 skill files exist with valid frontmatter containing `name:` and `description:`. Plan skill explicitly mentions NO TDD. Execute skill contains the convergence loop. Cleanup skill mentions acceptance gate.

Proof:
```bash
ls /Users/ken/workspace/ms/flywheel/claude-code/CLAUDE.md /Users/ken/workspace/ms/flywheel/claude-code/skills/*.md && echo "---" && grep -l "name:" /Users/ken/workspace/ms/flywheel/claude-code/skills/*.md && echo "---" && grep -c "NO TDD\|Theory of Success" /Users/ken/workspace/ms/flywheel/claude-code/skills/plan.md && echo "---" && grep -c "acceptance gate" /Users/ken/workspace/ms/flywheel/claude-code/skills/cleanup.md
```

NFR scan:
- Portability: CLAUDE.md and skills must work standalone — no `@flywheel:` references (Claude Code doesn't resolve those). All content must be self-contained.
- Discoverability: Each skill description must contain trigger words matching user intent.
- Completeness: All 4 phases covered. Missing a phase means the methodology is incomplete in Claude Code.

---

## Task 7: Shadow test infrastructure

Context: Shadow tests validate that the flywheel bundle is structurally correct without requiring an LLM invocation. This means: all required files exist, YAML is valid, no `@superpowers:` leakage, key content markers are present. The flywheel project already has empty directories at `tests/smoke/`. Docker is used for clean-room validation — the container copies the bundle and runs structural checks.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/tests/Dockerfile`
- Create: `/Users/ken/workspace/ms/flywheel/tests/smoke/test_amplifier_bundle.sh`
- Create: `/Users/ken/workspace/ms/flywheel/tests/smoke/run_smoke_tests.sh`

What to build:

**Dockerfile** at `/Users/ken/workspace/ms/flywheel/tests/Dockerfile`:

```dockerfile
FROM python:3.12-slim
RUN pip install pyyaml 2>/dev/null || echo "pyyaml install attempted"
COPY . /workspace/flywheel
WORKDIR /workspace/flywheel
CMD ["bash", "tests/smoke/run_smoke_tests.sh"]
```

Note: we install `pyyaml` (not amplifier) because we only need YAML validation. Keep the container minimal.

**test_amplifier_bundle.sh** at `/Users/ken/workspace/ms/flywheel/tests/smoke/test_amplifier_bundle.sh`:

```bash
#!/bin/bash
set -e
BUNDLE=/workspace/flywheel
ERRORS=0

check() {
  if [ -f "$1" ]; then echo "✓ $1"; else echo "✗ MISSING: $1"; ERRORS=$((ERRORS+1)); fi
}

echo "=== Flywheel Bundle Structural Validation ==="
echo ""

# Phase 1 files (bundle infrastructure)
echo "--- Phase 1: Bundle Infrastructure ---"
check "$BUNDLE/bundle.md"
check "$BUNDLE/behaviors/flywheel-methodology.yaml"
check "$BUNDLE/context/philosophy.md"
check "$BUNDLE/context/instructions.md"
check "$BUNDLE/modes/brainstorm.md"
check "$BUNDLE/modes/plan.md"
check "$BUNDLE/modes/execute.md"
check "$BUNDLE/modes/cleanup.md"

# Phase 2 files (agents, skills, plugin)
echo ""
echo "--- Phase 2: Agents ---"
check "$BUNDLE/agents/brainstormer.md"
check "$BUNDLE/agents/planner.md"
check "$BUNDLE/agents/implementer.md"
check "$BUNDLE/agents/verifier.md"

echo ""
echo "--- Phase 2: Skills ---"
check "$BUNDLE/skills/verification-rubric/SKILL.md"
check "$BUNDLE/skills/nfr-scan/SKILL.md"

echo ""
echo "--- Phase 2: Claude Code Plugin ---"
check "$BUNDLE/claude-code/CLAUDE.md"
check "$BUNDLE/claude-code/skills/brainstorm.md"
check "$BUNDLE/claude-code/skills/plan.md"
check "$BUNDLE/claude-code/skills/execute.md"
check "$BUNDLE/claude-code/skills/cleanup.md"

# YAML validity
echo ""
echo "--- Structural Checks ---"
python3 -c "import yaml; yaml.safe_load(open('$BUNDLE/behaviors/flywheel-methodology.yaml'))" && echo "✓ behavior YAML valid" || { echo "✗ behavior YAML invalid"; ERRORS=$((ERRORS+1)); }

# Namespace check (no @superpowers: leakage)
if grep -r "@superpowers:" "$BUNDLE/modes/" "$BUNDLE/agents/" "$BUNDLE/behaviors/" "$BUNDLE/context/" 2>/dev/null; then
  echo "✗ Found @superpowers: references — should be @flywheel:"
  ERRORS=$((ERRORS+1))
else
  echo "✓ No @superpowers: leakage"
fi

# Key content checks — methodology markers
echo ""
echo "--- Content Markers ---"
grep -q "Theory of Success" "$BUNDLE/agents/planner.md" && echo "✓ planner has Theory of Success" || { echo "✗ planner missing Theory of Success"; ERRORS=$((ERRORS+1)); }
grep -q "NO TDD" "$BUNDLE/agents/planner.md" && echo "✓ planner has NO TDD declaration" || { echo "✗ planner missing NO TDD"; ERRORS=$((ERRORS+1)); }
grep -qE "PROVEN|PROVEN_WITH_NOTES|BLOCKED" "$BUNDLE/agents/implementer.md" && echo "✓ implementer has status codes" || { echo "✗ implementer missing status codes"; ERRORS=$((ERRORS+1)); }
grep -qE "VERIFIED|NEEDS_MORE_PROOF|RETRY|REPLAN|RETHINK" "$BUNDLE/agents/verifier.md" && echo "✓ verifier has all verdict codes" || { echo "✗ verifier missing verdict codes"; ERRORS=$((ERRORS+1)); }
grep -q "Goldilocks" "$BUNDLE/agents/verifier.md" && echo "✓ verifier has Goldilocks rubric" || { echo "✗ verifier missing Goldilocks"; ERRORS=$((ERRORS+1)); }
grep -q "acceptance gate" "$BUNDLE/modes/cleanup.md" && echo "✓ cleanup has acceptance gate" || { echo "✗ cleanup missing acceptance gate"; ERRORS=$((ERRORS+1)); }
grep -q "Theory of Success" "$BUNDLE/modes/plan.md" && echo "✓ plan mode has Theory of Success" || { echo "✗ plan mode missing Theory of Success"; ERRORS=$((ERRORS+1)); }
grep -q "RETRY\|REPLAN\|RETHINK" "$BUNDLE/modes/execute.md" && echo "✓ execute mode has failure routing" || { echo "✗ execute mode missing failure routing"; ERRORS=$((ERRORS+1)); }

# Agent frontmatter checks
echo ""
echo "--- Agent Frontmatter ---"
for agent in brainstormer planner implementer verifier; do
  grep -q "name: $agent" "$BUNDLE/agents/$agent.md" && echo "✓ $agent has correct name in frontmatter" || { echo "✗ $agent missing name in frontmatter"; ERRORS=$((ERRORS+1)); }
done

# Skills frontmatter checks
echo ""
echo "--- Skills Frontmatter ---"
grep -q "name: verification-rubric" "$BUNDLE/skills/verification-rubric/SKILL.md" && echo "✓ verification-rubric skill has name" || { echo "✗ verification-rubric missing name"; ERRORS=$((ERRORS+1)); }
grep -q "name: nfr-scan" "$BUNDLE/skills/nfr-scan/SKILL.md" && echo "✓ nfr-scan skill has name" || { echo "✗ nfr-scan missing name"; ERRORS=$((ERRORS+1)); }

# Summary
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
else
  echo "$ERRORS CHECK(S) FAILED"
  exit 1
fi
```

**run_smoke_tests.sh** at `/Users/ken/workspace/ms/flywheel/tests/smoke/run_smoke_tests.sh`:

```bash
#!/bin/bash
set -e
echo "Running flywheel smoke tests..."
echo ""
bash "$(dirname "$0")/test_amplifier_bundle.sh"
```

After creating all three files, make the shell scripts executable:
```bash
chmod +x /Users/ken/workspace/ms/flywheel/tests/smoke/test_amplifier_bundle.sh
chmod +x /Users/ken/workspace/ms/flywheel/tests/smoke/run_smoke_tests.sh
```

Theory of Success: All 3 files exist. test_amplifier_bundle.sh checks all 19 required bundle files, validates YAML, checks for namespace leakage, validates content markers for all 4 agents and 4 modes, and checks skill frontmatter. Scripts are executable.

Proof:
```bash
ls -la /Users/ken/workspace/ms/flywheel/tests/smoke/*.sh /Users/ken/workspace/ms/flywheel/tests/Dockerfile && echo "---" && head -5 /Users/ken/workspace/ms/flywheel/tests/smoke/test_amplifier_bundle.sh && echo "---" && test -x /Users/ken/workspace/ms/flywheel/tests/smoke/test_amplifier_bundle.sh && echo "EXECUTABLE: YES" || echo "EXECUTABLE: NO"
```

NFR scan:
- Reliability: Scripts use `set -e` to fail fast. Error counter ensures all failures are reported, not just the first.
- Security: Container runs as default user, no secrets mounted, `--rm` flag on docker run.
- Portability: Only depends on bash, python3, grep — available in python:3.12-slim.

---

## Task 8: Run shadow tests in Docker container

Context: Tasks 1-7 must be complete before this task. All bundle files exist. The Docker container provides a clean-room environment to validate the bundle structure. If tests fail, the implementer must read the error, fix the affected file, rebuild, and re-run until all checks pass.

Files:
- No new files — this task runs the tests created in Task 7

What to build:

Build the Docker image:
```bash
cd /Users/ken/workspace/ms/flywheel
docker build -t flywheel-smoke -f tests/Dockerfile .
```

Run the smoke tests:
```bash
docker run --rm flywheel-smoke
```

If any checks fail:
1. Read the specific `✗` line to identify the failing check
2. Identify the affected file
3. Fix the issue (missing content, wrong frontmatter, namespace leakage, etc.)
4. Rebuild: `docker build -t flywheel-smoke -f tests/Dockerfile .`
5. Re-run: `docker run --rm flywheel-smoke`
6. Repeat until exit code 0

Theory of Success: `docker run --rm flywheel-smoke` exits with code 0 and output shows "ALL CHECKS PASSED" with zero `✗` lines.

Proof: The full output of `docker run --rm flywheel-smoke` showing all `✓` lines and "ALL CHECKS PASSED" at the end.

NFR scan:
- Reliability: Container is stateless (`--rm`) — each run is a clean room.
- Performance: Build should complete in <30 seconds (only `pip install pyyaml` + COPY).
- Security: No secrets, no network access needed, no volume mounts.

---

## Task 9: README.md + final commit + push to GitHub

Context: All bundle files, agents, skills, Claude Code plugin, and shadow tests are complete and passing. The README is the last file. The GitHub repo at `kenotron-ms/flywheel` was already created with the initial commit.

Files:
- Create: `/Users/ken/workspace/ms/flywheel/README.md`

What to build:

**README.md sections** — write in this order:

**1. Title + badge area:**
```markdown
# flywheel

Outcome-driven development methodology for [Amplifier](https://github.com/microsoft/amplifier) and Claude Code.
```

**2. What is flywheel?** (1 paragraph):
"Flywheel replaces activity-based development (did you do the thing?) with evidence loops (can you prove the thing works?). Every task defines what done looks like before execution starts, and execution isn't complete until evidence closes the loop. No TDD — Theory of Success instead."

**3. Quick Start — Amplifier:**
```markdown
## Quick Start — Amplifier

Add flywheel as an include in your `bundle.md`:

\```yaml
includes:
  - bundle: git+https://github.com/kenotron-ms/flywheel@main
\```

Then use the flywheel modes:
- `/brainstorm` — Design the thing
- `/plan` — Break into tasks with Theory of Success
- `/execute` — Build + prove each task
- `/cleanup` — Acceptance gate + ship it
```

**4. Quick Start — Claude Code:**
```markdown
## Quick Start — Claude Code

Copy `claude-code/CLAUDE.md` into your project root (or `~/.claude/CLAUDE.md` for global use).
Copy `claude-code/skills/` into your project's `.claude/skills/` directory.

The skills will guide you through the flywheel methodology without Amplifier.
```

**5. The 4 Phases:**
```markdown
## The 4 Phases

| Phase | Purpose | Output |
|-------|---------|--------|
| **Brainstorm** | Design the thing. Define what overall success looks like. | Design document |
| **Plan** | Break into tasks. Each task gets Theory of Success + proof action + NFR scan. | Implementation plan |
| **Execute** | Build each task. Run the proof. Return evidence. Verify with Goldilocks rubric. | Proven implementation |
| **Cleanup** | Acceptance gate (system-level proof). Then cleanup + commit. | Shipped work |

Forward progression is a ratchet (brainstorm → plan → execute → cleanup).
Backward routing is free: **RETRY** (re-run task), **REPLAN** (fix the plan), **RETHINK** (fix the design).
```

**6. Why flywheel?** (brief):
```markdown
## Why flywheel?

- **Theory of Success** — Define what done looks like before you start, not after
- **Outcome over activity** — Report what you proved, not what you did
- **Goldilocks verification** — Not too little proof, not too much, just right
- **NFR mindset** — Surface security/privacy/performance concerns at plan time, not in production
- **No TDD** — Evidence loops replace test-driven development
```

**7. Contributing:**
```markdown
## Contributing

This project welcomes contributions. Please open an issue to discuss changes before submitting a PR.
```

After creating README.md, commit and push:
```bash
cd /Users/ken/workspace/ms/flywheel
git add -A
git commit -m "feat: flywheel v0.1.0 — outcome-driven development methodology

Amplifier bundle + Claude Code plugin for evidence-based development.
4 agents (brainstormer, planner, implementer, verifier),
2 skills (verification-rubric, nfr-scan), 4 modes,
shadow test infrastructure.

Theory of Success: docker smoke tests pass, bundle loads in Amplifier,
Claude Code skills are self-contained."
git push origin main
```

Theory of Success: README.md exists with all 7 sections. `git push` succeeds. GitHub repo shows the complete flywheel project.

Proof:
```bash
cat /Users/ken/workspace/ms/flywheel/README.md | head -30 && echo "---" && git -C /Users/ken/workspace/ms/flywheel log --oneline | head -5 && echo "---" && gh repo view kenotron-ms/flywheel --json pushedAt,description 2>/dev/null || echo "gh not available — verify push manually"
```

NFR scan:
- Completeness: README must cover both Amplifier and Claude Code usage paths. Missing either means adoption friction.
- Accuracy: The `includes:` line in Quick Start must reference the actual GitHub repo URL (`kenotron-ms/flywheel`).
- Brevity: README should be scannable in <2 minutes. No walls of text.
