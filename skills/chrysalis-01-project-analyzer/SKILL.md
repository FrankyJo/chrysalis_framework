---
name: chrysalis-01-project-analyzer
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

## Output

Create two files in the project root:

**`PROJECT_INVENTORY.md`** — a table of all components: file, lines, framework, mixed responsibilities (yes/no + which), test coverage, usage count, risk rating.

**`REFACTOR_PLAN.md`** — the recommended order of refactoring phases (a list of components or groups, with a short justification for the order). Don't write detailed refactoring steps for each component here — that's the job of later phases; this file is only about order and reasoning.

If the project already has a `CLAUDE.md`, briefly compare its contents with what you just found (stack, conventions) and note any discrepancies at the end of `PROJECT_INVENTORY.md` — but don't edit `CLAUDE.md` itself.

## Stop

After creating both files — **stop**. Give a short summary (3-5 sentences): how many components were analyzed, how many are top-priority candidates, which one is the first recommended component. Ask whether the human agrees with the order, and suggest the next step:

> "Ready to start with `chrysalis-02-component-analyzer` for [component name] whenever you say so."

Do not start the next phase yourself.
