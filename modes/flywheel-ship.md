---
    mode:
      name: flywheel-ship
      description: Acceptance gate and completion - verify the whole system works, clean up, commit with evidence summary
      shortcut: flywheel-ship

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
      allowed_transitions: [flywheel-execute, flywheel-plan, flywheel-design]
      allow_clear: true
---

    FLYWHEEL-SHIP MODE: Acceptance gate → cleanup → commit → done.

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
    | **RETRY** | `/flywheel-execute` | System almost works — specific task needs re-execution |
    | **REPLAN** | `/flywheel-plan` | System doesn't deliver because the plan missed something |
    | **RETHINK** | `/flywheel-design` | System doesn't deliver because the idea itself was wrong |

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
    "I'm entering flywheel-ship mode. Two steps: (1) acceptance gate — does the whole system deliver on the Theory of Success? Cannot skip. (2) Cleanup and commit — only after the gate passes."

    ## Transitions

    **Done when:** Committed/pushed/PR created

    **Golden path:** Session complete
    - Tell user: "Completed via [chosen option]. Evidence committed."
    - Use `mode(operation='clear')` to exit modes.

    **Dynamic transitions:**
    - If acceptance gate fails with RETRY → use `mode(operation='set', name='flywheel-execute')` because a specific task needs re-execution
    - If acceptance gate fails with REPLAN → use `mode(operation='set', name='flywheel-plan')` because the plan missed something
    - If acceptance gate fails with RETHINK → use `mode(operation='set', name='flywheel-design')` because the design needs revision
    - If user wants more work on this project → use `mode(operation='set', name='flywheel-design')` because new work needs the design process

    **Skill connection:** If you load a workflow skill,
    the skill tells you WHAT to do. This mode enforces HOW. They complement each other.
    