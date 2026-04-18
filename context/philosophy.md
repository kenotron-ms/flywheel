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
    