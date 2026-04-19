---
name: cleanup
description: Use when user types /cleanup to enter flywheel cleanup mode for the acceptance gate and commit.
disable-model-invocation: true
---

Activate flywheel cleanup mode now.

Call `mode(operation="set", name="cleanup")` to activate cleanup mode.

Note: This uses a warn gate policy. If the first call is denied, call once more to confirm the transition.
