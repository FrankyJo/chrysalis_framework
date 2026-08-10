---
name: ch-component-analyzer
description: Phase 2 of Chrysalis. Performs a deep, single-component analysis (Vue/React/Angular) before any refactoring starts — responsibilities, dependencies, state, edge cases, existing test gaps. Use when the user names a specific component/file to refactor next, says "analyze this component", "break down [file] in detail before refactoring", or continues Chrysalis after phase 1 (project-analyzer) by picking a target component. Requires that a specific component has already been chosen — if the user hasn't picked one yet, point them to ch-project-analyzer first.
---

# Phase 2: Component Analyzer

You are executing the SECOND phase of Chrysalis — a deep analysis of ONE specific component chosen by the human. **Do not edit any code file.**

## Determine the target component

- If you were invoked with an argument (a filename or path — e.g. `ReportForm.vue` or `src/components/ReportForm.vue`), that's the target. If it's a bare filename, search the project for a matching component file; if more than one file matches, list them and ask the user which one.
- If you were invoked with no argument, use the top entry from `REFACTOR_PLAN.md` (phase 1 output) if it exists, and say explicitly that you're using it — don't silently guess if there's no `REFACTOR_PLAN.md` and no argument; ask the user instead.
- Compute `<component-slug>`: kebab-case of the component's base filename, without extension (e.g. `ReportForm.vue` → `report-form`).
- If `.claude/chrysalis/module-plan.md` exists, look up this component's current path in its mapping table. If there's a row for it, note the target module path — this component will be physically relocated later by `ch-relocate`, after `ch-verify` passes. If there's no row (or the file doesn't exist), this component just gets refactored in place, same as always.

As soon as the target is confirmed, write `.claude/chrysalis/state.json` (create the file if it doesn't exist, overwrite if it does):

```json
{
  "current_component": "<component-slug>",
  "current_component_path": "<path/to/Component.vue>",
  "target_module_path": "<target path from module-plan.md, or null if none>",
  "relocated": false,
  "last_phase_completed": 2,
  "updated": "<today's date>"
}
```

This is what lets the later phases (`ch-test-baseline`, `ch-visual-baseline`, `ch-execute`, `ch-verify`, `ch-report`) know which component to continue with when the human invokes them without repeating the component name.

## Why this matters

Before touching the code, you need to understand the component's ENTIRE behavior — including the non-obvious parts: side effects, edge cases, hidden dependencies on global state. A detail missed here is a regression after the refactor.

## What to analyze

1. **Responsibilities** — list every separate "job" the component currently does (rendering UI, API calls, form validation, date formatting, event subscriptions, global store interaction, etc.). A bloated component usually does 4-8 different things at once.
2. **Public contract** — props/emits (Vue), props/callbacks (React), @Input/@Output (Angular). This is what CANNOT change without a separate discussion — other parts of the system depend on it.
3. **State dependencies** — which store actions/mutations/getters (Vuex/Pinia), context/Redux selectors, or Angular services it uses. Build a short list of "where data comes in, where changes go out".
4. **Side effects and edge cases** — async requests (loading/error/empty states), timers, subscriptions, localStorage/window access, conditional rendering based on role/feature flags, i18n-specific logic (pluralization, RTL, etc.).
5. **Existing tests** — what already exists, what exactly it checks, what it does NOT cover.
6. **Risk** — which parts are easiest to break silently (e.g. a non-obvious condition for showing an element, API error handling, an empty-array edge case).

## Where to store artifacts

All artifacts from this component's refactor cycle (this phase and phases 3-7) are stored in `.claude/chrysalis/changes/<component-slug>/`, where `<component-slug>` is the kebab-case component name without extension (e.g. `UserProfileCard.vue` → `user-profile-card`). This folder is keyed by the component's NAME, not its location in the project — so multiple components in the same directory (`src/components/`) don't overwrite each other's artifacts. Create this folder now if it doesn't exist yet.

This is not an OpenSpec-style archive — the folder is never moved or merged anywhere once the refactor is done. It simply stops being used until someone explicitly asks to revisit this component.

## Output

Create `.claude/chrysalis/changes/<component-slug>/ANALYSIS.md`, structured as:

```markdown
# Analysis: <component name>

## Responsibilities
...

## Public contract (DO NOT change without agreement)
...

## Target module (if modularizing)
<Target path from module-plan.md, or "Not in module-plan.md — stays in place">

## State dependencies
...

## Side effects and edge cases
...

## Current test coverage
Yes / no, what's covered, gaps.

## Risk areas
...

## Recommended refactoring approach
Briefly: which pieces of logic to extract into composables/hooks/services first, whether the template can be split into subcomponents, whether there are natural split boundaries.
```

## Stop

Give a short summary (the riskiest areas, the main recommendation) and ask for confirmation to continue:

> "Ready to write characterization tests for `<component-slug>` via `ch-test-baseline` whenever you say so — it'll pick up this component automatically."

Do not start the next phase yourself.
