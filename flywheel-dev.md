---
    bundle:
      name: flywheel
      version: 0.1.0
      description: |
        Daily driver — lean amplifier-dev foundation + flywheel methodology.
        Dev-focused alternate entry point: 71% token reduction from standard foundation.

        Lean dev tooling: git-ops, explorer, bug-hunter, zen-architect, modular-builder,
        Python/LSP, apply_patch — plus the complete flywheel methodology
        (flywheel-design, flywheel-plan, flywheel-execute, flywheel-ship).

      includes:
        - bundle: git+https://github.com/microsoft/amplifier-foundation@main#subdirectory=experiments/exp-lean/behaviors/lean-foundation.yaml
        - bundle: git+https://github.com/microsoft/amplifier-foundation@main#subdirectory=experiments/exp-lean/behaviors/lean-amplifier-dev.yaml
        - bundle: flywheel:behaviors/flywheel-methodology
        - bundle: flywheel:behaviors/flywheel-dev-skills
    ---

    # Flywheel Dev — Daily Driver

    Outcome-driven development with lean tooling. Evidence over assertions. Close the loop before moving on.

    @flywheel:context/philosophy.md
    @flywheel:context/instructions.md
    