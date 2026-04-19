---
    name: flywheel-cleanup
    description: Use when all tasks are executed — acceptance gate then cleanup work. Triggers include "cleanup", "finish", "wrap up", "acceptance gate", "are we done", "ship it".
    disable-model-invocation: true
    ---

    # Flywheel Cleanup Phase

    ## Two Steps in Sequence — Cannot Skip Step 1

    **Step 1 must pass before Step 2 begins.**

    ## Step 1: Acceptance Gate (CANNOT SKIP)

    **Question:** Does the system as a whole deliver on the Theory of Success defined in brainstorm?

    This is NOT a re-check of individual tasks — execute already closed those loops. This is a single system-level question.

    ### How to Run
    1. Find the overall Theory of Success from the design document
    2. Run or observe the system **as a user would** — not through internal APIs or unit tests
    3. Evaluate the evidence against the Theory of Success

    ### Gate Results

    **PASS:**
    ```
    Acceptance gate PASSED.
    Overall Theory of Success: [state it]
    Evidence: [what you ran/observed]
    Result: System delivers on the stated outcome.
    Proceeding to cleanup.
    ```
    → Step 2 unlocks.

    **FAIL:**
    ```
    Acceptance gate FAILED.
    Overall Theory of Success: [state it]
    Evidence: [what you ran/observed]
    Gap: [specific gap]
    Classification: [RETRY / REPLAN / RETHINK]
    Reason: [why]
    ```
    → Route back:
    - **RETRY** → back to execute (specific task needs re-run)
    - **REPLAN** → back to plan (plan missed something)
    - **RETHINK** → back to brainstorm (design was wrong)

    ## Step 2: Cleanup Work (Only After Gate PASSES)

    ### 2a: Remove Artifacts
    - Temp files, debug logs, experimental scaffolding
    - Resolved TODO comments
    - Test fixtures no longer needed

    ### 2b: Commit with Evidence Summary
    ```bash
    git add -A
    git commit -m "feat: [feature name]

    Proven:
    - [evidence from task 1]
    - [evidence from task 2]
    - ...

    Acceptance gate: [overall Theory of Success] — PASSED"
    ```

    Evidence-based commit message. Not activity-based.

    ### 2c: Choose Completion Option

    Present 3 options:
    1. **LOCAL** — Keep as local commit (already done)
    2. **PUSH** — Push to remote: `git push origin <branch>`
    3. **PR** — Push and open a Pull Request

    ## Do NOT
    - Skip the acceptance gate
    - Begin cleanup before the gate passes
    - Write activity-based commit messages ("Created auth.ts, added validation...")
    - Route back without classifying the failure
    