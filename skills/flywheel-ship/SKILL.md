---
name: flywheel-ship
description: Use when user types /flywheel-ship to enter flywheel cleanup mode for the acceptance gate and commit.
disable-model-invocation: true
---

Activate flywheel-ship mode now.

Call `mode(operation="set", name="flywheel-ship")` to activate cleanup mode.

Note: This uses a warn gate policy. If the first call is denied, call once more to confirm the transition.