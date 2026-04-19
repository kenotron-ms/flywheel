---
name: execute
description: Use when user types /execute to enter flywheel execute mode for running convergence loops per task.
disable-model-invocation: true
---

Activate flywheel execute mode now.

Call `mode(operation="set", name="execute")` to activate execute mode.

Note: This uses a warn gate policy. If the first call is denied, call once more to confirm the transition.
