---
name: chrysalis-07-report
description: Phase 7 (final) of Chrysalis. Produces the final human-readable report for a refactored component — summary of changes, automated test/visual results, a tailored manual-test checklist, and the next recommended component. Use after chrysalis-06-verify has returned PASS or WARN, when the user says "summarize what was done", "give me the final report", or continues Chrysalis pipeline to close out a component. This is the final human decision gate — never treat automated PASS as equivalent to human sign-off.
---

# Phase 7: Final Report

You are executing the LAST phase for this component — pulling everything together into one clear report for the human who makes the final merge decision.

## Why this matters

Automated tests and the visual diff (if there was one) are necessary but not sufficient. There are things they structurally can't catch: real behavior against the backend, analytics/tracking, browser/device-specific bugs, subjective UX feel. This phase doesn't "automatically say everything's fine" — it prepares the human to check that effectively themselves, knowing exactly where to look most carefully.

## Gather everything

From `.claude/chrysalis/changes/<component-slug>/` read: `ANALYSIS.md` (phase 2), `TEST_BASELINE.md` (phase 3), the visual-baseline state (phase 4, including `VISUAL_BASELINE_SKIPPED.md` if present), `CHANGES.md` (phase 5), `VERIFY_REPORT.md` (phase 6).

## Build the manual-test checklist

This is the most important part of the report. Prioritize by risk:

1. Everything marked "deliberately not covered" in `TEST_BASELINE.md`.
2. If the visual check was skipped (no Playwright) — every state that should have been checked automatically now becomes a manual-check item, with a clear explanation why.
3. Risk areas from `ANALYSIS.md` that are theoretically covered by tests but are worth checking "against live data" (a real API, real user data, not mocks).
4. Cross-browser/cross-device checks, if the component is responsive and Playwright didn't test every viewport.

## Output

`.claude/chrysalis/changes/<component-slug>/FINAL_REPORT.md`:

```markdown
# Final Report: <component name>

## What changed
[brief, based on CHANGES.md]

## Automated verification
Tests: X/X. Visual diff: [passed / skipped — Playwright not connected].

## ⚠️ What to check manually
[prioritized checklist]

## Recommendation
[ready to merge pending the manual checks above / needs extra attention because of X]

## Next component
[from REFACTOR_PLAN.md — name and short justification for why it's next]
```

## Living component reference (separate from FINAL_REPORT.md)

Unlike `.claude/chrysalis/changes/<component-slug>/` (which stops being used right after this phase — it's the history of a single refactor cycle, never merged or archived anywhere), create or update `.claude/chrysalis/docs/<component-slug>.md` — a document that lives indefinitely and is meant for ANY future edits to this component, not just refactoring:

```markdown
# <component name> — reference

Last updated: <date>, after a refactor via Chrysalis.

## Architecture after the refactor
[composables/hooks/services extracted, how the component interacts with them]

## Public contract
[props/emits — as of now]

## Known edge cases and risk areas
[from ANALYSIS.md — what's still not covered by tests or remains fragile]

## State dependencies
[store actions/mutations/getters the component uses]
```

If such a file already exists from a previous refactor cycle of the same component, update it — don't create a duplicate.

If the project root has a `CLAUDE.md` and it doesn't yet have a rule about automatically reading `.claude/chrysalis/docs/`, suggest the user add one (don't edit `CLAUDE.md` yourself without confirmation):

> Before editing a component file under `src/components/` (or the equivalent folder), check whether `.claude/chrysalis/docs/<component-slug>.md` exists (slug = kebab-case component name). If it does, read it first — it holds the component's current architecture after its last refactor.

## Stop

Present the report in the chat (not just the file) and clearly state that this is not an automatic approval — the merge decision is the human's. Ask:

> "This wraps up the refactor for this component. Move straight to the next one (`chrysalis-01-project-analyzer` already pointed to [next component] — start with `chrysalis-02-component-analyzer`), or stop here for manual review?"
