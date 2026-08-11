---
name: ch-execute
description: Phase 5 of Chrysalis. Executes the actual refactor of a component's internal structure following framework-specific best practices (Vue composables, React hooks, Angular services), without changing its public API. Use only after ch-visual-baseline has completed for the target component (or was explicitly skipped), when the user says "now refactor this component", "let's do the actual changes", or continues Chrysalis pipeline into the execute phase. Do not use this to make arbitrary code changes unrelated to the pipeline — it assumes ANALYSIS.md and a test baseline already exist for the component.
---

# Phase 5: Execute Refactor

You are executing the FIFTH phase — the actual code refactor. This is the only phase where you actually change the component's files.

## Which component this runs on

- If invoked with an argument (a filename/path), use that component, overriding the session state below.
- Otherwise, read `.claude/chrysalis/state.json` and use its `current_component` / `current_component_path`. If the file doesn't exist or has no `current_component`, stop and tell the user to run `ch-component-analyzer <component>` first.
- State which component you're operating on before doing anything else.
- When this phase finishes, update `.claude/chrysalis/state.json`: set `last_phase_completed` to `5`.

## Before you start

Make sure `ANALYSIS.md` (phase 2) and `TEST_BASELINE.md` (phase 3) already exist in `.claude/chrysalis/changes/<component-slug>/`. If they don't — stop and say the earlier phases need to run first; don't refactor a component "blind".

Read the reference matching the framework (determined in phase 1/2):
- Vue → `references/vue.md`
- React → `references/react.md`
- Angular → `references/angular.md`

## Where new extracted files go

Don't drop every extracted composable/hook/service into one flat, shared directory (`composables/`, `hooks/`, `services/`) — across multiple refactors that becomes an unsorted junk drawer with no indication of which file belongs to which component. Instead:

1. Check whether the project already has a precedent for grouping related files into a topic subfolder (e.g. a `components/<topic>/` folder holding several flat files for one feature area). If so, mirror that exact pattern.
2. Otherwise, default to a subfolder per component, named with `<component-slug>` — the same kebab-case slug already used for `.claude/chrysalis/changes/<component-slug>/`: e.g. `src/composables/<component-slug>/useXxx.js` (Vue), `src/hooks/<component-slug>/useXxx.js` (React), `src/app/<component-slug>/services/xxx.service.ts` or the project's existing Angular module layout (Angular).

Since these are brand-new files with no existing importers, nesting them like this needs no project-wide import search — that's what makes it safe to do inside this phase, unlike relocating the component itself (`ch-relocate`'s job, not this one).

## Main rule

**The component's public contract (props/emits, props/callbacks, @Input/@Output) does not change**, unless the human explicitly asked for that separately. The refactor is about INTERNAL structure — how the component is built, not how it's interacted with from outside. This is what makes the refactor safe: every place that uses the component keeps working unchanged.

## Steps

1. Follow the split boundary from `ANALYSIS.md`'s "Recommended refactoring approach" — that's already been confirmed with the human in phase 2, so don't redesign it here. If mid-refactor you find a good reason to deviate, stop and check with the human rather than silently picking a different boundary. Make one logical change at a time, in order of increasing risk: first extract business logic into a composable/hook/service (the safest step — purely mechanical code movement), then split the template/JSX into subcomponents (a structural change, higher risk of touching markup).
2. After each logical step, run the existing tests (from phase 3) as a quick self-check. This isn't the final verification (that's phase 6), just a fast signal for "did I obviously break something".
3. If a test fails, figure out whether it's a real regression (fix the code) or the test was too tied to the internal implementation rather than to behavior (then fix the test, but note this in the report — the test may have been written the wrong way).
4. Don't make "while I'm at it" improvements unrelated to the stated refactor goal (renaming variables for no reason, reformatting, updating dependencies, fixing unrelated bugs, dropping unused params/imports you happen to notice) — every extra change makes it harder to diagnose if something goes wrong. Note anything you noticed but deliberately left alone in `CHANGES.md` so it isn't lost, but leave the code itself untouched.
5. Add a short JSDoc/TSDoc comment (a couple of lines — what it does, what its parameters are, what it returns) on every function a new composable/hook/service returns publicly. This is additive documentation, not a behavior change, so it's fine to include as part of the extraction itself — it costs nothing in regression risk and the new file has no such documentation otherwise.
6. Commit in logical chunks (separate commits for "extracted composable", "split template"), if the project is under git — this makes it easier to roll back a specific step instead of the whole refactor.

## Output

Changed component code (in place, in the normal project structure) + a short `.claude/chrysalis/changes/<component-slug>/CHANGES.md`: what exactly was moved/split, why it was done that way, whether there were any deviations from the plan in `ANALYSIS.md`.

## Stop

Give a summary of the changes and the result of the test run (self-check). Ask for confirmation to continue:

> "The refactor is done, the quick tests pass. Ready for final verification via `ch-verify` (full test run + visual diff) whenever you say so — it'll pick up this component automatically."

Do not start the next phase yourself.
