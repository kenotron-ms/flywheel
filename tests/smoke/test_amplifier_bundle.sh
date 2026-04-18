#!/bin/bash
    set -e
    BUNDLE=/workspace/flywheel
    ERRORS=0

    check() {
      if [ -f "$1" ]; then echo "✓ $1"; else echo "✗ MISSING: $1"; ERRORS=$((ERRORS+1)); fi
    }

    echo "=== Flywheel Bundle Structural Validation ==="
    echo ""

    # Phase 1 files (bundle infrastructure)
    echo "--- Phase 1: Bundle Infrastructure ---"
    check "$BUNDLE/bundle.md"
    check "$BUNDLE/behaviors/flywheel-methodology.yaml"
    check "$BUNDLE/context/philosophy.md"
    check "$BUNDLE/context/instructions.md"
    check "$BUNDLE/modes/brainstorm.md"
    check "$BUNDLE/modes/plan.md"
    check "$BUNDLE/modes/execute.md"
    check "$BUNDLE/modes/cleanup.md"

    # Phase 2 files (agents, skills, plugin)
    echo ""
    echo "--- Phase 2: Agents ---"
    check "$BUNDLE/agents/brainstormer.md"
    check "$BUNDLE/agents/planner.md"
    check "$BUNDLE/agents/implementer.md"
    check "$BUNDLE/agents/verifier.md"

    echo ""
    echo "--- Phase 2: Skills ---"
    check "$BUNDLE/skills/verification-rubric/SKILL.md"
    check "$BUNDLE/skills/nfr-scan/SKILL.md"

    echo ""
    echo "--- Phase 2: Claude Code Plugin ---"
    check "$BUNDLE/claude-code/CLAUDE.md"
    check "$BUNDLE/claude-code/skills/brainstorm.md"
    check "$BUNDLE/claude-code/skills/plan.md"
    check "$BUNDLE/claude-code/skills/execute.md"
    check "$BUNDLE/claude-code/skills/cleanup.md"

    # YAML validity
    echo ""
    echo "--- Structural Checks ---"
    python3 -c "import yaml; yaml.safe_load(open('$BUNDLE/behaviors/flywheel-methodology.yaml'))" && echo "✓ behavior YAML valid" || { echo "✗ behavior YAML invalid"; ERRORS=$((ERRORS+1)); }

    # Namespace check (no @superpowers: leakage)
    if grep -r "@superpowers:" "$BUNDLE/modes/" "$BUNDLE/agents/" "$BUNDLE/behaviors/" "$BUNDLE/context/" 2>/dev/null; then
      echo "✗ Found @superpowers: references — should be @flywheel:"
      ERRORS=$((ERRORS+1))
    else
      echo "✓ No @superpowers: leakage"
    fi

    # Key content checks — methodology markers
    echo ""
    echo "--- Content Markers ---"
    grep -q "Theory of Success" "$BUNDLE/agents/planner.md" && echo "✓ planner has Theory of Success" || { echo "✗ planner missing Theory of Success"; ERRORS=$((ERRORS+1)); }
    grep -q "NO TDD" "$BUNDLE/agents/planner.md" && echo "✓ planner has NO TDD declaration" || { echo "✗ planner missing NO TDD"; ERRORS=$((ERRORS+1)); }
    grep -qE "PROVEN|PROVEN_WITH_NOTES|BLOCKED" "$BUNDLE/agents/implementer.md" && echo "✓ implementer has status codes" || { echo "✗ implementer missing status codes"; ERRORS=$((ERRORS+1)); }
    grep -qE "VERIFIED|NEEDS_MORE_PROOF|RETRY|REPLAN|RETHINK" "$BUNDLE/agents/verifier.md" && echo "✓ verifier has all verdict codes" || { echo "✗ verifier missing verdict codes"; ERRORS=$((ERRORS+1)); }
    grep -q "Goldilocks" "$BUNDLE/agents/verifier.md" && echo "✓ verifier has Goldilocks rubric" || { echo "✗ verifier missing Goldilocks"; ERRORS=$((ERRORS+1)); }
    grep -q "acceptance gate" "$BUNDLE/modes/cleanup.md" && echo "✓ cleanup has acceptance gate" || { echo "✗ cleanup missing acceptance gate"; ERRORS=$((ERRORS+1)); }
    grep -q "Theory of Success" "$BUNDLE/modes/plan.md" && echo "✓ plan mode has Theory of Success" || { echo "✗ plan mode missing Theory of Success"; ERRORS=$((ERRORS+1)); }
    grep -qE "RETRY|REPLAN|RETHINK" "$BUNDLE/modes/execute.md" && echo "✓ execute mode has failure routing" || { echo "✗ execute mode missing failure routing"; ERRORS=$((ERRORS+1)); }

    # Agent frontmatter checks
    echo ""
    echo "--- Agent Frontmatter ---"
    for agent in brainstormer planner implementer verifier; do
      grep -q "name: $agent" "$BUNDLE/agents/$agent.md" && echo "✓ $agent has correct name in frontmatter" || { echo "✗ $agent missing name in frontmatter"; ERRORS=$((ERRORS+1)); }
    done

    # Skills frontmatter checks
    echo ""
    echo "--- Skills Frontmatter ---"
    grep -q "name: verification-rubric" "$BUNDLE/skills/verification-rubric/SKILL.md" && echo "✓ verification-rubric skill has name" || { echo "✗ verification-rubric missing name"; ERRORS=$((ERRORS+1)); }
    grep -q "name: nfr-scan" "$BUNDLE/skills/nfr-scan/SKILL.md" && echo "✓ nfr-scan skill has name" || { echo "✗ nfr-scan missing name"; ERRORS=$((ERRORS+1)); }

    # Summary
    echo ""
    echo "================================"
    if [ $ERRORS -eq 0 ]; then
      echo "ALL CHECKS PASSED"
      exit 0
    else
      echo "$ERRORS CHECK(S) FAILED"
      exit 1
    fi
    