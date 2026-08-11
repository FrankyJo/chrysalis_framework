---
name: ch-project-analyzer
description: Phase 1 of Chrysalis. Scans an entire Vue/React/Angular frontend project to find bloated, tangled-logic components and produces a prioritized refactoring plan. Use this whenever the user wants to start a refactoring initiative, asks "which components should I refactor first", "analyze my project for refactoring", "find bloated components", "build a refactoring plan", or mentions starting Chrysalis from phase 1 / project analysis. This is always the first phase — run it before any component-level work.
---

# Phase 1: Project Analyzer

You are executing the FIRST phase of Chrysalis — analysis of the entire project. **Do not edit any code file.** Your job is analysis and documentation only.

## Why this matters

Refactoring without a plan leads to chaotic changes and regressions. The goal of this phase is to give the human a picture of the whole project: where the biggest risk is, where to start (the safest place), and in what order to move so that every next step builds on an already-stabilized base.

## Step 1. Identify the framework and stack

Look at `package.json` and the file structure:
- `vue` in dependencies + `.vue` files → Vue (check the version: 2 or 3, Options or Composition API, is `<script setup>` used?)
- `react`/`react-dom` + `.jsx`/`.tsx` files → React
- `@angular/core` + `.component.ts` files → Angular

Also record: state management (Vuex/Pinia/Redux/NgRx/services), the UI library, TypeScript or not, which test runner is already configured (Vitest/Jest/Jasmine/Karma/Playwright), the linter and its rules.

## Step 2. Scan the components

For every component file, determine:

- line count;
- whether responsibilities are mixed in one file (API calls, business logic, validation, UI all at once);
- dependencies on global state (which store actions/mutations/selectors it uses);
- whether unit/e2e tests exist and roughly how much coverage there is (look for neighboring `*.spec.*` / `*.test.*` files);
- how many times the component is imported/reused;
- coupling level with other components (props/emits, context/inputs-outputs, provide-inject).

If the project has a lint rule for complexity (`complexity`, `max-lines`), run the linter and use its output instead of counting by hand.

## Step 3. Prioritize

Sort components by refactoring priority — this is NOT the same as just "biggest first". Priority = (size × complexity × regression risk) adjusted for value:

- Start with components that have a small blast radius (few dependencies, few usage sites) — mistakes there are cheapest and confidence in the process builds fastest.
- Components with zero tests and high coupling (many store dependencies, many importers) are the riskiest — save them for later, once there's experience from previous iterations.
- Very bloated but isolated components (few importers) are good early candidates: high visible impact, low risk.

## Step 4. Flag whether modularization is worth considering

Look at how the components you just inventoried sit on disk. If most of them live flat in one shared directory (no subfolders, or only incidental ones) and there are roughly 15+ of them, this project is a good candidate for running `ch-module-plan` before working through components one by one. Say why, concretely: `ch-execute`'s per-component subfolder convention for composables/hooks/services (`<component-slug>/`) makes clear *whose* extracted logic something is, but it says nothing about *what groups with what* — at 15+ components in one flat directory, that's the harder readability problem, and only actually drawing module/feature boundaries (`ch-module-plan` + `ch-relocate`) solves it. Below that rough size, or if components already sit in sensible topic subfolders, don't bother raising it — in-place cleanup alone will stay readable.

This is a recommendation surfaced once, up front, while it's cheap to act on — not a requirement. The human decides whether they want in-place cleanup only or full modularization, and can always run `ch-module-plan` later even if skipped now.

## Output

Create two files in the project root:

**`PROJECT_INVENTORY.md`** — a table of all components: file, lines, framework, mixed responsibilities (yes/no + which), test coverage, usage count, risk rating.

**`REFACTOR_PLAN.md`** — the recommended order of refactoring phases (a list of components or groups, with a short justification for the order), plus a **Modularization** section: whether Step 4 flagged this project as a good candidate for `ch-module-plan` and why (or a one-line "not flagged" if it didn't). Don't write detailed refactoring steps for each component here — that's the job of later phases; this file is only about order and reasoning.

If the project already has a `CLAUDE.md`, briefly compare its contents with what you just found (stack, conventions) and note any discrepancies at the end of `PROJECT_INVENTORY.md` — but don't edit `CLAUDE.md` itself.

## Stop

After creating both files — **stop**. Give a short summary (3-5 sentences): how many components were analyzed, how many are top-priority candidates, which one is the first recommended component. Ask whether the human agrees with the order, and suggest the next step — branching on whether Step 4 flagged modularization:

- **Flagged** → "Ready to start with `ch-component-analyzer` for [component name] whenever you say so. One thing worth deciding first, though: this project has [N] components mostly flat in one directory — before diving in component-by-component, consider running `ch-module-plan` to define feature/module boundaries up front, so composables and (later, if you want it) relocated components land somewhere sensible from the start instead of needing to move twice. Your call — in-place cleanup works fine without it too."
- **Not flagged** → "Ready to start with `ch-component-analyzer` for [component name] whenever you say so."

Do not start the next phase yourself.
