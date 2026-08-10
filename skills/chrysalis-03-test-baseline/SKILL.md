---
name: chrysalis-03-test-baseline
description: Phase 3 of Chrysalis. Writes characterization tests that lock in a component's CURRENT behavior before it gets refactored, so any later regression is caught automatically. Use after chrysalis-02-component-analyzer has produced an ANALYSIS.md for a component, when the user says "write tests before refactoring", "cover this component with tests", or continues Chrysalis pipeline into the test-baseline phase. Do not use this for general "write tests for my app" requests unrelated to the refactor pipeline — use only when a component has already been through phase 2 analysis.
---

# Phase 3: Test Baseline

You are executing the THIRD phase — locking in the component's CURRENT behavior with tests, BEFORE anyone changes it. These are characterization tests: they describe "what the component does now", not "what it should ideally do". The goal is a safety net, not a test refactor.

## Why this matters

If tests pass after the refactor, that should mean "behavior didn't change". But this only works if the tests were written BEFORE the changes, based on `ANALYSIS.md` from the previous phase, and not rewritten afterward — otherwise they'll just confirm the new (possibly broken) behavior.

## Steps

1. Read this component's `.claude/chrysalis/changes/<component-slug>/ANALYSIS.md` (from phase 2) — the list of responsibilities, edge cases, public contract.
2. Determine which test runner is already in the project (Vitest/Jest/Testing Library/Jasmine+Karma/Angular Testing Utilities) — use it, don't propose a new tool at this stage.
3. For every responsibility and edge case from `ANALYSIS.md`, write a test: render with different props/inputs, check emits/callbacks, mock API calls (success/error/empty response), check conditional rendering.
4. Prioritize by risk: test the riskiest areas from `ANALYSIS.md` first, not everything indiscriminately.
5. **Run the tests against the CURRENT (not-yet-refactored) code.** All of them must pass — if a test fails now, it's describing NOT the current behavior but your idea of correct behavior. Fix the test, not the component (the component isn't touched yet).
6. If some edge case can't be covered by a unit test (e.g. real layout/CSS, drag-and-drop, browser-specific APIs), don't try to force a brittle test. Add it to the "not covered" list — it becomes a subject for visual review (phase 4) or manual testing (phase 7).

## Output

- Test files next to the component (following the project's convention) — this is code, it stays in the normal project structure, not in `.claude/chrysalis/changes/`.
- `.claude/chrysalis/changes/<component-slug>/TEST_BASELINE.md`:

```markdown
# Test Baseline: <component name>

## Covered by tests
- ...

## Deliberately NOT covered (and why)
- ... (carry over to the manual-test checklist in phase 7)

## Run result
X/X tests pass on the current (pre-refactor) code.
```

## Stop

Give a summary: how many tests were written, whether everything passes, what's left uncovered. Ask for confirmation:

> "Tests have locked in the current behavior. Ready to move to `chrysalis-04-visual-baseline` (screenshots of the states) whenever you say so."

Do not start the next phase yourself.
