---
    name: flywheel-execute
    description: Use when executing a plan — convergence loop per task with implementer and verifier roles. Triggers include "execute", "implement the plan", "start building", "run the plan", "let's build it".
    ---

    # Flywheel Execute Phase

    ## Your Role

    Orchestrate task-by-task execution using convergence loops. You dispatch, route verdicts, and escalate. You do NOT implement. You do NOT verify. You dispatch and route.

    ## The Convergence Loop (Per Task)

    For each task in the plan:

    1. **Announce**: "Starting Task N: [title]"
    2. **Implement**: Implement the task. Run the proof action VERBATIM. Return status.
    3. **Verify**: Evaluate evidence against the Theory of Success using the Goldilocks rubric.
    4. **Route** based on verdict:
       - `VERIFIED` → "Task N: VERIFIED ✓" → next task
       - `NEEDS_MORE_PROOF` + gap → address the specific gap → back to step 2
       - `RETRY` + reason → re-run the task fresh → back to step 2
       - `REPLAN` + reason → exit to plan phase
       - `RETHINK` + reason → exit to brainstorm phase

    ## Implementer Status Codes

    The implementer (you when doing the work) returns exactly one:

    ```
    PROVEN
    [raw output of proof action]
    ```

    ```
    PROVEN_WITH_NOTES
    [raw output of proof action]
    Note: [one-sentence concern]
    ```

    ```
    BLOCKED
    Need: [what's missing]
    ```

    ## Verifier Verdicts

    After implementing, verify the evidence using the Goldilocks rubric:

    ```
    VERIFIED
    ```

    ```
    NEEDS_MORE_PROOF
    Gap: [specific gap — one sentence]
    ```

    ```
    RETRY
    Reason: [what went wrong]
    ```

    ```
    REPLAN
    Reason: [what's wrong with the plan]
    ```

    ```
    RETHINK
    Reason: [what design assumption failed]
    ```

    ## Goldilocks Rubric Summary

    | Task type | Minimum | Sufficient | Never demand |
    |-----------|---------|------------|--------------|
    | UI change | Screenshot | Screenshot + interaction | Full test suite |
    | API endpoint | curl with status | curl with headers + body | Load test |
    | DB migration | row count | count + schema | Full integrity check |
    | Config change | grep of key | grep + behaviour diff | Unit test |
    | Refactor | tests pass | test output + diff | Re-implementation |
    | File creation | file exists | content grep + validity | Line-by-line review |

    ## Token Discipline

    - Return outcomes, not narration
    - "Task N: VERIFIED ✓" not "I reviewed the evidence and found..."
    - Evidence output verbatim, not paraphrased

    ## Convergence Limits

    If a task hasn't converged in 3 iterations:
    - Assess: is the verifier over-demanding? (Goldilocks violation)
    - If real gaps persist: escalate to user with: what was tried, what evidence was produced, your classification (RETRY/REPLAN/RETHINK), options

    ## Completion

    When all tasks are verified:
    ```
    ## Execution Complete
    All [N] tasks implemented and verified.
    [x] Task 1: [description] — VERIFIED ✓
    ...
    Next: load cleanup.md for the acceptance gate.
    ```
    