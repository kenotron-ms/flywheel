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
    /flywheel-design  →  Design Document (with overall Theory of Success)
          |
    /flywheel-plan  →  Task Plan (Theory of Success + NFR scan per task)
          |
    /flywheel-execute  →  Convergence Loops
          |        Per Task:
          |        1. Implementer builds + runs proof action
          |        2. Verifier evaluates evidence against Theory of Success
          |        3. Loop until VERIFIED or escalate (RETRY/REPLAN/RETHINK)
          |
    /flywheel-ship  →  Acceptance gate → cleanup → commit/push/PR
    ```

    **One track, four modes:**

    | Command | Purpose | Next Step |
    |---------|---------|-----------|
    | `/flywheel-design` | Refine idea into design, define overall Theory of Success | `/flywheel-plan` |
    | `/flywheel-plan` | Create task plan with Theory of Success + NFR scan per task | `/flywheel-execute` |
    | `/flywheel-execute` | Convergence loops: implementer proves, verifier evaluates | `/flywheel-ship` |
    | `/flywheel-ship` | Acceptance gate → cleanup → commit/push/PR | Done |

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
    