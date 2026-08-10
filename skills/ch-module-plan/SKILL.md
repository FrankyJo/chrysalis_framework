---
name: ch-module-plan
description: Optional phase of Chrysalis, run after ch-project-analyzer and before working on individual components. Defines target module/feature boundaries for a monolithic frontend project and produces a path-mapping plan (current component path → target module) that ch-component-analyzer and ch-relocate read later to physically move refactored components into modules. Use when the user wants to break a monolith into modules/features, asks "how should I split this into modules", "define module boundaries", "modularize this project", "turn this monolith into modules". Skip this entirely if the user only wants in-place component refactoring — it is optional and nothing else in Chrysalis depends on it existing.
---

# Optional Phase: Module Plan

You are defining the TARGET module/feature boundaries for a monolithic project, before any component-level work happens. **Do not edit or move any file.** This phase only plans; `ch-relocate` (a later, per-component phase) is what actually moves files.

## Why this matters

Moving files across module boundaries is a fundamentally different kind of risk than refactoring inside one file: every import path that references the moved file breaks unless it's updated everywhere, and a badly drawn boundary creates circular dependencies or duplicated logic between modules. Planning boundaries once, up front, for the whole project — instead of improvising per component — keeps this consistent and gives every later relocation one source of truth to check against.

## Step 1. Determine module boundaries

Default strategy: **feature/domain-based modules** — group by business capability (e.g. `modules/reports/`, `modules/users/`, `modules/billing/`), not by technical layer. This is framework-agnostic and doesn't require adopting a prescriptive architecture. If the user explicitly wants Feature-Sliced Design layers (app/pages/widgets/features/entities/shared) instead, that's a bigger, more opinionated restructure — the dedicated `fsd-migration` skill is built specifically for whole-project FSD adoption and may be a better fit; confirm with the user which they actually want before proceeding.

To find natural boundaries, look at:
- Which components/composables/store modules are consistently used together (import graph clustering).
- Existing naming clues (e.g. `Report*.vue`, `report.store.js` likely belong together).
- Route structure — routes/pages often already imply feature boundaries.
- `PROJECT_INVENTORY.md` from phase 1, if it exists, for the full component list.

Don't force every file into a module immediately. Components with unclear or cross-cutting ownership (shared UI primitives, generic utilities) can stay unassigned — see Step 3.

## Step 2. Confirm with the human

Propose the module list (name, one-line scope, rough list of components/files each would contain) and **stop to get explicit confirmation before writing the plan file**. Getting boundaries wrong is expensive to undo once files start moving — this is the one place in this phase worth pausing for agreement before producing output, not just after.

## Step 3. Write the plan

Once confirmed, create `.claude/chrysalis/module-plan.md`:

```markdown
# Module Plan

Strategy: <feature-based | FSD | other, as agreed with the human>

## Modules

### <module-name>
Scope: <one-line description of what belongs here>

| Current path | Target path |
|---|---|
| src/components/ReportForm.vue | src/modules/reports/components/ReportForm.vue |
| ... | ... |

### <module-name>
...

## Unassigned (cross-cutting or unclear ownership — left in place for now)
- src/components/SharedButton.vue — used by 12 components across modules, not clearly owned by one
```

This file is the single source of truth that `ch-component-analyzer` and `ch-relocate` read later — a component only gets physically moved if it has a row here.

## Stop

Summarize how many modules were defined, how many components got a target, how many stayed unassigned (and why). Ask for confirmation, then suggest the next step:

> "The module plan is ready. Ready to start with `ch-component-analyzer` for [first component] whenever you say so — it'll pick up its target module from this plan automatically."

Do not start component-level work yourself.
