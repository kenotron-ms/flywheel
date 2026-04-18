# flywheel

Outcome-driven development methodology for [Amplifier](https://github.com/microsoft/amplifier) and Claude Code.

## What is flywheel?

Flywheel replaces activity-based development (did you do the thing?) with evidence loops (can you prove the thing works?). Every task defines what done looks like before execution starts, and execution isn't complete until evidence closes the loop. No TDD — Theory of Success instead.

## Quick Start — Amplifier

Add flywheel as an include in your `bundle.md`:

```yaml
includes:
  - bundle: git+https://github.com/kenotron-ms/flywheel@main
```

Then use the flywheel modes:
- `/brainstorm` — Design the thing
- `/plan` — Break into tasks with Theory of Success
- `/execute` — Build + prove each task
- `/cleanup` — Acceptance gate + ship it

## Quick Start — Claude Code

Copy `claude-code/CLAUDE.md` into your project root (or `~/.claude/CLAUDE.md` for global use).
Copy `claude-code/skills/` into your project's `.claude/skills/` directory.

The skills will guide you through the flywheel methodology without Amplifier.

## The 4 Phases

| Phase | Purpose | Output |
|-------|---------|--------|
| **Brainstorm** | Design the thing. Define what overall success looks like. | Design document |
| **Plan** | Break into tasks. Each task gets Theory of Success + proof action + NFR scan. | Implementation plan |
| **Execute** | Build each task. Run the proof. Return evidence. Verify with Goldilocks rubric. | Proven implementation |
| **Cleanup** | Acceptance gate (system-level proof). Then cleanup + commit. | Shipped work |

Forward progression is a ratchet (brainstorm → plan → execute → cleanup).
Backward routing is free: **RETRY** (re-run task), **REPLAN** (fix the plan), **RETHINK** (fix the design).

## Why flywheel?

- **Theory of Success** — Define what done looks like before you start, not after
- **Outcome over activity** — Report what you proved, not what you did
- **Goldilocks verification** — Not too little proof, not too much, just right
- **NFR mindset** — Surface security/privacy/performance concerns at plan time, not in production
- **No TDD** — Evidence loops replace test-driven development

## Contributing

This project welcomes contributions. Please open an issue to discuss changes before submitting a PR.
