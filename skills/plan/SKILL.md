---
name: plan
description: Use when user types /plan to enter flywheel plan mode for writing Theory of Success task plans.
disable-model-invocation: true
---

Activate flywheel plan mode now.

Call `mode(operation="set", name="plan")` to activate plan mode.

Note: This uses a warn gate policy. If the first call is denied, call once more to confirm the transition.
