---
    name: flywheel-plan
    description: Use when creating an implementation plan — Theory of Success per task, superpowers-level detail, NO TDD. Triggers include "plan", "create tasks", "break this down", "implementation plan", "write the tasks".
    ---

    # Flywheel Plan Phase

    ## Your Role

    Create an implementation plan where every task has a Theory of Success — an observable outcome with a specific proof action. You produce superpowers-level detail PLUS evidence-based verification per task.

    ## Task Format (Required Structure)

    Every task must contain ALL THREE parts:

    ```markdown
    ### Task N: [Title]

    Context: [relevant files, existing patterns to follow, what prior tasks built]

    What to build:
    - [specific — exact file paths, function signatures, naming conventions]
    - [complete code — not "add validation" but the actual code]
    - [exact commands — not "test the endpoint" but the actual curl]

    Theory of Success: [what done looks like to an observer — the outcome, not the activity]
    Proof: [specific runnable action — curl, grep, screenshot, query — that proves it]

    NFR scan:
    - [concern]: [what "good enough" means for this task]
    - [concern]: [what "good enough" means for this task]
    ```

    ## What This Plan Does NOT Contain

    **NO TDD steps. No RED/GREEN/REFACTOR. No "write failing test first."**

    The Theory of Success IS the verification. A curl showing the actual response proves more than a test that asserts a status code.

    ## Before Writing

    1. Read the design document
    2. Search for existing patterns — naming conventions, directory structure
    3. Verify file paths exist
    4. Note imports and dependencies already available

    ## Plan Header (Required)

    ```markdown
    # [Feature Name] Implementation Plan

    > **For execution:** Use the flywheel execute phase.

    **Goal:** [One sentence]
    **No TDD.** Tasks use Theory of Success format.

    ---
    ```

    ## Plan Size Rule

    Plans with more than 15 tasks should be split into phases. Each phase gets its own document.

    ## Content Rules

    - **Exact file paths** — always
    - **Complete code** when showing code — not "add validation"
    - **Exact proof commands** — with expected output format
    - **Theory of Success** — observable outcome, not "it works"
    - **NFR scan** — 2-3 lines per task

    ## Output

    Plan saved to `docs/plans/YYYY-MM-DD-<feature>-plan.md`.

    ## Transition

    "Plan ready. Load `execute.md` for the execution phase."
    