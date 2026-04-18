---
    name: verification-rubric
    description: Use when evaluating evidence quality — calibrate verification effort to task complexity using the Goldilocks rubric. Triggers include "is this enough proof", "how much evidence do I need", "verify this", "evaluate evidence", "Goldilocks".
    ---

    # Goldilocks Verification Rubric

    Every task has a Theory of Success. The rubric calibrates how much evidence is needed to close the loop — not too little (under-verification), not too much (over-verification), just right.

    ## The Rubric Table

    | Task Type | Minimum Proof | Sufficient | Over-Verification (NEVER demand) |
    |-----------|--------------|------------|----------------------------------|
    | UI change | Screenshot of affected state | Screenshot + interaction proof if interactive | Full automation suite |
    | API endpoint | Single curl with status code | Request + response headers + body | Load test |
    | DB migration | Row count or schema query | Count + schema describe | Full integrity check |
    | Config change | grep of changed key | Output + behaviour diff | Unit test of config parsing |
    | Refactor | Existing tests still pass | Test output + diff summary | Re-implementation |
    | Script/automation | Script output with expected values | Output + input→output traceability | Coverage report |
    | File creation | File exists with required content | Content grep + structural validity check | Manual line-by-line review |

    ## Guidance Per Task Type

    ### UI change
    Minimum: a screenshot showing the affected component in the expected state.
    Sufficient: a screenshot showing the state, plus a second screenshot or recording showing interaction (click, hover, scroll) if the change was interactive.
    Over: setting up Playwright/Cypress for a one-time visual check — automation is for regressions, not first-time verification.

    ### API endpoint
    Minimum: `curl -s URL` showing the status code.
    Sufficient: full curl with `-v` or `-i` showing request, response headers, and body.
    Over: setting up a load test or writing an integration test suite for first-time verification.

    ### DB migration
    Minimum: `SELECT COUNT(*) FROM table` or `\d table` showing the new column or table exists.
    Sufficient: count + full schema describe + a sample row showing data is correct.
    Over: running a full data integrity check across all rows or writing migration rollback tests.

    ### Config change
    Minimum: `grep 'key' config.yaml` (or equivalent) showing the changed value.
    Sufficient: grep output + running the system and showing the behaviour actually changed (not just the file changed).
    Over: writing a unit test for config file parsing — this tests the test, not the config.

    ### Refactor
    Minimum: existing test suite passes (show the passing output).
    Sufficient: test output + a brief diff summary showing what changed structurally.
    Over: re-implementing the feature from scratch to verify the refactor was correct.

    ### Script/automation
    Minimum: run the script, show output contains expected values.
    Sufficient: run with known input, show clear input→output traceability (what went in, what came out).
    Over: writing a coverage report or test harness for the script itself.

    ### File creation
    Minimum: `ls -la file` + `head file` showing it exists with content.
    Sufficient: targeted grep for required content + structural check (valid YAML, valid JSON, etc.).
    Over: manual line-by-line review of every line in the file.

    ## Calibration Principle

    When in doubt, aim for Sufficient. If you are debating between Sufficient and Over — stop at Sufficient.

    The goal is confidence, not certainty. Perfect verification is an enemy of shipping.

    A VERIFIED verdict on sufficient evidence is correct. Demanding more when sufficient evidence exists is a Goldilocks violation that wastes tokens and slows the convergence loop.
    