---
    name: nfr-scan
    description: Use when planning tasks to surface non-functional concerns early — security, privacy, performance, resource contention, reliability. Triggers include "NFR", "non-functional", "security scan", "privacy check", "performance concern", "plan a task".
    ---

    # Lightweight NFR Scan

    Every task in a flywheel plan gets a lightweight NFR scan — 2-3 lines identifying which non-functional concerns apply and what "good enough" means. This surfaces concerns at planning time, not in production.

    ## The 5 Concern Types

    ### Security
    **Questions to ask:**
    - Does this handle user input?
    - Does it touch auth/authz?
    - Does it expose new attack surface?
    - Does it handle sensitive data?

    **"Good enough" heuristic:** validate and sanitize input, use parameterized queries, don't log secrets or tokens, validate on the server not just client.

    **Example:** "Security: validate JWT signature, not just decode. Check expiry. Reject tampered tokens."

    ---

    ### Privacy
    **Questions to ask:**
    - Does this handle PII (names, emails, IDs)?
    - Does it create new data flows?
    - Could it accidentally log sensitive data?
    - Does it store data that doesn't need to be stored?

    **"Good enough" heuristic:** no PII in logs, no PII in error messages, minimal data collection (only what's needed), handle data deletion if applicable.

    **Example:** "Privacy: no PII in token payload or application logs."

    ---

    ### Performance
    **Questions to ask:**
    - Is this on a hot path (called per request, per event)?
    - Could it cause N+1 queries?
    - Does it involve large datasets or unbounded lists?
    - Does it do work that could be done once but is done repeatedly?

    **"Good enough" heuristic:** no DB call per request if avoidable, pagination for lists over 100 items, cache where the pattern is obviously repeated.

    **Example:** "Performance: no DB call per request — validation is stateless. Cache token issuer config."

    ---

    ### Resource Contention
    **Questions to ask:**
    - Does this acquire locks?
    - Does it write to shared state (file, DB row, in-memory dict)?
    - Could concurrent requests conflict?
    - Does it hold a resource across an async wait?

    **"Good enough" heuristic:** use atomic operations, avoid long-held locks, consider retry logic for contention, use database transactions for multi-step writes.

    **Example:** "Resource: file writes use atomic rename to prevent partial writes. No lock held across network call."

    ---

    ### Reliability
    **Questions to ask:**
    - What happens when this fails?
    - Is there a fallback or graceful degradation?
    - Is it idempotent (can it be safely retried)?
    - Does it fail open or fail closed (which is correct for this use case)?

    **"Good enough" heuristic:** meaningful error messages (not stack traces to users), graceful degradation when dependencies are down, idempotent where retries are possible.

    **Example:** "Reliability: retry with backoff on transient network errors. Fail closed on auth errors — don't allow through."

    ## Using the Scan

    Not every concern applies to every task. A file creation task rarely has performance concerns. A config change rarely has privacy concerns.

    Include only what's relevant — the scan is 2-3 lines, not a threat model. The explicit decision to exclude a concern is still valuable: it shows you thought about it and ruled it out.

    **Format in the plan:**
    ```
    NFR scan:
    - Security: [concern and good-enough definition, or "No security concerns"]
    - Performance: [concern and good-enough definition]
    - [other concerns if relevant]
    ```

    The scan is there to catch the obvious thing you'd miss at implementation time. It doesn't replace a security audit — it prevents the most common oversights.
    