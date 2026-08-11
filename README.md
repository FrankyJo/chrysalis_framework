# Chrysalis (Vue / React / Angular)

A set of skills for Claude Code that carries out a safe, phased refactor of frontend components (Vue 3, React, Angular) with a human checkpoint at every step. A core 7-phase pipeline refactors one component's internals in place; two optional phases extend that into breaking a monolith into modules.

## Installation

### Quick install (recommended)

Run this from the root of the project you want to refactor:

```bash
curl -fsSL https://raw.githubusercontent.com/FrankyJo/chrysalis_framework/main/install.sh | bash
```

This installs the skills into that project's `.claude/skills/` (project-scoped). To install for all your projects instead, add `-s -- --global`:

```bash
curl -fsSL https://raw.githubusercontent.com/FrankyJo/chrysalis_framework/main/install.sh | bash -s -- --global
```

### Manual install

Clone or download this repo, then copy `skills/` into your project's `.claude/skills/` (project-scoped, visible only in this project) or into `~/.claude/skills/` (available in all projects):

```bash
git clone https://github.com/FrankyJo/chrysalis_framework.git
cp -r chrysalis_framework/skills/* /path/to/your/project/.claude/skills/
```

Either way, restart Claude Code (or start a new session) so the skills are picked up.

## Philosophy

- **A human gate at every phase.** No skill moves on to the next phase automatically — it always stops, reports, and waits for your explicit "continue" before the next step.
- **Safety net first, changes second.** Before touching a component's code, its current behavior is locked in with tests and (where possible) screenshots. Only then does refactoring happen.
- **The public API doesn't change without a separate request.** Props/emits/inputs/outputs stay compatible — the refactor is about internal structure.
- **Playwright is optional, but recommended.** If the Playwright MCP server isn't connected, the framework keeps going, it just skips the visual regression step and clearly flags that in every report where it matters.

## Where artifacts live

All intermediate artifacts from phases 2-7 (analysis, tests, screenshots, reports) for a given component live in `.claude/chrysalis/changes/<component-slug>/`, where `<component-slug>` is the kebab-case component name (e.g. `UserProfileCard.vue` → `user-profile-card`). The folder is keyed by the component's NAME, not its location in the project, so multiple components in the same directory (`src/components/`) never overwrite each other's artifacts.

Unlike OpenSpec, this folder is never archived or merged anywhere once the work is done — it simply stops being used until someone explicitly asks to revisit that component.

Separately, at the end of the report phase, `.claude/chrysalis/docs/<component-slug>.md` is created or updated — a living reference for the component (location, architecture, public contract, known risks) that isn't tied to a single refactor cycle and is meant for any future edits to that component. The report phase will itself suggest adding a rule to the project's `CLAUDE.md` so Claude Code automatically picks up this reference in future sessions, even ones unrelated to the framework.

Note that artifacts are keyed by the component's **slug** (its name), not its file path — which is what lets a component keep the same `.claude/chrysalis/changes/<slug>/` folder even after `ch-relocate` moves its actual file to a new path.

## Phase order

The core pipeline (phases 1-7) refactors one component's internals in place — nothing about it changes if you never touch modularization. Two optional phases (marked below) extend it to also break a monolith into modules; skip them entirely if you only want in-place cleanup.

| # | Skill | What it does | Output |
|---|------|-----------|-----------|
| 1 | `ch-project-analyzer` | Scans the whole project, identifies the framework, finds bloated/tangled components | `PROJECT_INVENTORY.md`, `REFACTOR_PLAN.md` (in project root) |
| *optional* | `ch-module-plan` | Defines target module/feature boundaries for the whole project and a path-mapping plan | `.claude/chrysalis/module-plan.md` (in project root) |
| 2 | `ch-component-analyzer` | Deep analysis of ONE chosen component (picks up its module-plan target, if any) | `.claude/chrysalis/changes/<slug>/ANALYSIS.md` |
| 3 | `ch-test-baseline` | Writes characterization tests for current behavior | test files (next to the component), `.claude/chrysalis/changes/<slug>/TEST_BASELINE.md` |
| 4 | `ch-visual-baseline` | Checks/offers to install Playwright MCP, captures screenshots of all states BEFORE changes | `.claude/chrysalis/changes/<slug>/visual-baseline/*.png` or `VISUAL_BASELINE_SKIPPED.md` |
| 5 | `ch-execute` | The actual refactor, following framework best practices | changed component code (in place), `.claude/chrysalis/changes/<slug>/CHANGES.md` |
| 6 | `ch-verify` | Full test run + (if available) before/after Playwright diff | `.claude/chrysalis/changes/<slug>/VERIFY_REPORT.md` |
| *optional* | `ch-relocate` | Only if this component has a module-plan target: moves it into its module and rewrites every import project-wide, gated on a full build | `.claude/chrysalis/changes/<slug>/RELOCATE_REPORT.md` |
| 7 | `ch-report` | Summary for the human + manual-test checklist + next component | `.claude/chrysalis/changes/<slug>/FINAL_REPORT.md`, `.claude/chrysalis/docs/<slug>.md` |

## How to run it

Each skill is also a slash command, named after its folder. Run it directly, or just describe what you want in plain English:

```
/ch-project-analyzer
/ch-module-plan            (optional — only if you want to modularize)
/ch-component-analyzer ReportForm.vue
/ch-test-baseline
/ch-visual-baseline
/ch-execute
/ch-verify
/ch-relocate                (optional — only runs if this component has a module-plan target)
/ch-report
```

Only `/ch-component-analyzer` needs an argument (the component to analyze — a filename or path). Every phase after it (`ch-test-baseline` through `ch-report`) picks up the "current component" automatically, so you don't have to repeat the name each time — see below. Each skill tells you when it's done and what to run next; you decide whether to move on or stop and take a look yourself.

## Remembering which component you're on

`ch-component-analyzer` writes `.claude/chrysalis/state.json`, recording the component slug, its file path, and which phase was last completed. Every later phase reads that file when you invoke it without an argument, so once you run:

```
/ch-component-analyzer ReportForm.vue
```

...the skill's closing message will point you to the next command (e.g. `ch-test-baseline`), and you can just run it bare:

```
/ch-test-baseline
```

...and it'll know you mean `report-form`, confirming that in its first line so a mix-up is caught immediately. You can still pass an explicit component argument to any phase to override this and work on a different component's cycle. Once `ch-report` closes out a component, it clears the state file, so the next bare invocation of `ch-component-analyzer` starts a clean cycle.

## Modularizing a monolith (optional)

The core pipeline never moves a file or touches an import path outside it — that keeps its safety net (characterization tests + visual baseline) meaningful, since it's only ever verifying "did this file's behavior change", not "did I break something three modules away". Breaking a monolith into feature modules is a different, bigger kind of risk (every call site that imports a moved file needs updating, and a badly drawn boundary creates circular dependencies), so it's opt-in and gated separately.

`ch-project-analyzer` (phase 1) flags this proactively when it looks relevant — roughly 15+ components sitting flat in one shared directory — so you see the recommendation once, up front, before spending effort refactoring components one at a time into a layout you might want to reshuffle later. Below that rough size, or if components already sit in sensible topic subfolders, it won't raise it. Either way, it's your call:

1. Run `/ch-module-plan` once, after `/ch-project-analyzer`. It proposes module boundaries (feature/domain-based by default), gets your explicit sign-off, and writes `.claude/chrysalis/module-plan.md` — a table of current path → target module for the components you want moved. If you want strict Feature-Sliced Design layers instead of simple feature modules, say so — the framework-specific `fsd-migration` skill is built for that and may be a better fit for a whole-project FSD adoption.
2. Run the normal per-component pipeline (`ch-component-analyzer` through `ch-verify`) as usual. `ch-component-analyzer` reads `module-plan.md` and records the target module in `ANALYSIS.md` if this component has one.
3. If `ch-verify` passes and the component has a module-plan target, it'll point you to `/ch-relocate` instead of straight to `/ch-report`. That phase moves the component (and whatever was extracted for it) to its target path, rewrites every import across the project, and gates on a full project build/typecheck — not just the component's own tests — before handing off to `/ch-report`.

Components with no row in `module-plan.md` are simply never touched by `ch-relocate` — they refactor in place exactly as before.
