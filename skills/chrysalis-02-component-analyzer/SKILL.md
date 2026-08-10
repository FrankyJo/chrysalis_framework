---
name: chrysalis-02-component-analyzer
description: Phase 2 of Chrysalis. Performs a deep, single-component analysis (Vue/React/Angular) before any refactoring starts — responsibilities, dependencies, state, edge cases, existing test gaps. Use when the user names a specific component/file to refactor next, says "analyze this component", "break down [file] in detail before refactoring", or continues Chrysalis after phase 1 (project-analyzer) by picking a target component. Requires that a specific component has already been chosen — if the user hasn't picked one yet, point them to chrysalis-01-project-analyzer first.
---

# Phase 2: Component Analyzer

You are executing the SECOND phase of Chrysalis — a deep analysis of ONE specific component chosen by the human (or picked from `REFACTOR_PLAN.md` if they just say "next"). **Do not edit any code file.**

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

> "Ready to write characterization tests for this component via `chrysalis-03-test-baseline` whenever you say so."

Do not start the next phase yourself.
