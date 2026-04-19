# Flywheel: Outcome-Driven Development

    Flywheel is a development methodology that replaces activity completion with evidence loops.
    Instead of "did you do the thing?", the question is "can you prove the thing works?"

    ## The 4 Phases

    1. **Brainstorm** — Design the thing. Define what overall success looks like.
    2. **Plan** — Break into tasks. Each task gets a Theory of Success + proof action + NFR scan.
    3. **Execute** — Build each task. Run the proof. Return evidence. Verify with Goldilocks rubric.
    4. **Cleanup** — Acceptance gate (system-level proof). Then cleanup + commit.

    ## How to Use

    Start with brainstorm. Progress forward: flywheel-design → flywheel-plan → flywheel-execute → flywheel-ship.
    Any failure routes backward: RETRY (re-run task), REPLAN (fix the plan), RETHINK (fix the design).

    ## Skills

    Load a phase skill for detailed guidance:
    - `flywheel-design.md` — Design phase with Theory of Success emphasis
    - `plan.md` — Planning with Theory of Success per task (NO TDD)
    - `execute.md` — Convergence loop with implementer → verifier pipeline
    - `cleanup.md` — Acceptance gate + cleanup work

    ## Core Principles

    - **Theory of Success over tests** — Define what done looks like, then prove it
    - **Outcome over activity** — Report what you proved, not what you did
    - **Goldilocks verification** — Not too little proof, not too much, just right
    - **NFR mindset** — Surface security/privacy/performance concerns at plan time, not in production
    - **No TDD** — Evidence loops replace test-driven development
    