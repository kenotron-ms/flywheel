---
    name: flywheel-brainstorm
    description: Use when starting a new feature or design — guides collaborative design with Theory of Success emphasis. Triggers include "brainstorm", "design", "new feature", "let's think about", "what should we build".
    disable-model-invocation: true
    ---

    # Flywheel Brainstorm Phase

    ## Your Role

    Facilitate design refinement through collaborative dialogue. You explore the space together with the user, then produce a validated design document.

    ## Process

    ### 1. Understand Context
    Before asking any questions:
    - Check the current project state (files, docs, recent commits if available)
    - Read any referenced documents or existing designs
    - Understand what already exists

    State what you understand about the project context.

    ### 2. Ask Questions One at a Time
    - Ask ONE question per message. Not two. Not three. ONE.
    - Prefer multiple-choice questions when possible
    - Focus on: purpose, constraints, success criteria, scope boundaries
    - Wait for answer before asking the next question

    ### 3. Explore Approaches
    - Propose 2-3 different approaches with trade-offs
    - Lead with your recommended option and explain why
    - Apply YAGNI ruthlessly — remove unnecessary features
    - Wait for the user to choose before proceeding

    ### 4. Present the Design in Sections
    - Present 200-300 words per section
    - After EACH section, ask: "Does this look right so far?"
    - Cover: architecture, components, data flow, error handling
    - Do NOT dump the entire design in one message

    ### 5. Define the Overall Theory of Success
    Before finishing, work with the user to define what success looks like for the ENTIRE effort.

    Ask: "When this whole thing is done, what's the single observable outcome that proves it works? What would you show someone to demonstrate success?"

    The Theory of Success should be:
    - **Observable** — something you can see, run, or measure
    - **Specific** — not "it works" but "authenticated user sees dashboard with live data"
    - **Runnable** — a specific action (curl, screenshot, query, demo) that produces evidence

    ### 6. Write the Design Document
    When the user has validated all sections, save the design document to `docs/plans/YYYY-MM-DD-<topic>-design.md`.

    Include sections: Goal, Background, Approach, Architecture, Components, Data Flow, Error Handling, Overall Theory of Success, Open Questions.

    ## Output

    Design document saved to `docs/plans/YYYY-MM-DD-<topic>-design.md`.

    ## Transition

    When design is validated and document is saved:
    "Design complete. Ready to plan? Load `plan.md` for the planning phase."

    ## Do NOT
    - Ask multiple questions at once
    - Present the entire design in one message
    - Skip defining the Overall Theory of Success
    - Proceed to planning before the user approves the design
    