---
name: ch-verify
description: Phase 6 of Chrysalis. Runs the full test suite and, if Playwright MCP is available, a before/after visual screenshot diff to confirm a just-refactored component still behaves and looks the same. Use after ch-execute completes, when the user says "verify nothing broke", "run tests and compare screenshots", or continues Chrysalis pipeline into the verify phase. This is the automated regression gate before the final human report.
---

# Phase 6: Verify

You are executing the SIXTH phase — an automated check that the refactor (phase 5) didn't break the component's behavior or appearance. This is a gate before the final report to the human (phase 7) — not a final "everything's fine" confirmation, but a signal for "is it worth going to the human now, or should something be fixed first".

## Which component this runs on

- If invoked with an argument (a filename/path), use that component, overriding the session state below.
- Otherwise, read `.claude/chrysalis/state.json` and use its `current_component` / `current_component_path`. If the file doesn't exist or has no `current_component`, stop and tell the user to run `ch-component-analyzer <component>` first.
- State which component you're operating on before doing anything else.
- When this phase finishes, update `.claude/chrysalis/state.json`: set `last_phase_completed` to `6` (only if the verdict is PASS or WARN — see below).

## Step 1. Full test run

Run ALL of the component's tests (from phase 3, plus any adjacent/integration tests touching this component or its composables/hooks/services). Record pass/fail for each.

If there are tests deliberately marked "not covered" in `.claude/chrysalis/changes/<component-slug>/TEST_BASELINE.md` — remind that they remain automatically uncovered, and this goes into the manual-test checklist.

## Step 2. Visual diff (if Playwright MCP is available)

Run `scripts/check_playwright.sh`.

- **If exit 0** and `.claude/chrysalis/changes/<component-slug>/visual-baseline/manifest.json` exists from phase 4: reproduce the SAME states on the REFACTORED code, take new screenshots, compare pixel-by-pixel (or via whatever comparison mechanism is available in Playwright MCP) against the "before" screenshots. For each state, record: matched / diverged (and how significant — cosmetic vs. structural).
- **If exit 1/2, or `VISUAL_BASELINE_SKIPPED.md` exists in `.claude/chrysalis/changes/<component-slug>/`**: skip this step, but **make sure to repeat the warning** in the report: "Visual regression was NOT checked automatically — Playwright MCP was not connected during this refactor. Review the component manually in the browser before merging."

## Step 3. Determine the verdict

- **PASS** — all tests pass, the visual diff (if any) shows no significant differences → ready for human review.
- **FAIL (tests)** — some tests failed → do NOT move to phase 7. Describe specifically what failed and the likely cause, recommend returning to `ch-execute` to fix it, or, if the problem runs deeper, consider rolling back (git revert / checkpoint) this component.
- **FAIL (visual)** — tests pass but there's a structural visual difference → same as above, return to phase 5, describing which part of the markup changed.
- **WARN (no visual check)** — tests pass, visuals weren't checked automatically → it's fine to move to phase 7, but with an explicit warning.

## Output

`.claude/chrysalis/changes/<component-slug>/VERIFY_REPORT.md`:

```markdown
# Verify Report: <component name>

## Tests
X/X pass. [details of failures, if any]

## Visual diff
[Compared N states, N differences] or [Skipped — Playwright MCP not connected]

## Verdict
PASS / FAIL / WARN + reasoning
```

## Stop

State the verdict and the main reason. If PASS or WARN, check `.claude/chrysalis/state.json`'s `target_module_path` (set by `ch-component-analyzer` from `module-plan.md`, if any):

- **Has a target module** → "Verification passed [with a warning about the missing visual diff, if applicable]. This component is slated for module `<target>` in `module-plan.md` — ready to relocate it via `ch-relocate` whenever you say so."
- **No target module** → "Verification passed [with a warning about the missing visual diff, if applicable]. Ready to put together the final report via `ch-report` whenever you say so — it'll pick up this component automatically."

If FAIL — clearly state that the next step is returning to `ch-execute`, and don't suggest moving on (to either `ch-relocate` or `ch-report`) until it's PASS/WARN.
