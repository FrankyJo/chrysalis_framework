# Chrysalis (Vue / React / Angular)

A set of 7 skills for Claude Code that carries out a safe, phased refactor of frontend components (Vue 3, React, Angular) with a human checkpoint at every step.

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

Separately, at the end of phase 7, `.claude/chrysalis/docs/<component-slug>.md` is created or updated — a living reference for the component (architecture, public contract, known risks) that isn't tied to a single refactor cycle and is meant for any future edits to that component. Phase 7 will itself suggest adding a rule to the project's `CLAUDE.md` so Claude Code automatically picks up this reference in future sessions, even ones unrelated to the framework.

## Phase order

| # | Skill | What it does | Output |
|---|------|-----------|-----------|
| 1 | `chrysalis-01-project-analyzer` | Scans the whole project, identifies the framework, finds bloated/tangled components | `PROJECT_INVENTORY.md`, `REFACTOR_PLAN.md` (in project root) |
| 2 | `chrysalis-02-component-analyzer` | Deep analysis of ONE chosen component | `.claude/chrysalis/changes/<slug>/ANALYSIS.md` |
| 3 | `chrysalis-03-test-baseline` | Writes characterization tests for current behavior | test files (next to the component), `.claude/chrysalis/changes/<slug>/TEST_BASELINE.md` |
| 4 | `chrysalis-04-visual-baseline` | Checks/offers to install Playwright MCP, captures screenshots of all states BEFORE changes | `.claude/chrysalis/changes/<slug>/visual-baseline/*.png` or `VISUAL_BASELINE_SKIPPED.md` |
| 5 | `chrysalis-05-execute` | The actual refactor, following framework best practices | changed component code (in place), `.claude/chrysalis/changes/<slug>/CHANGES.md` |
| 6 | `chrysalis-06-verify` | Full test run + (if available) before/after Playwright diff | `.claude/chrysalis/changes/<slug>/VERIFY_REPORT.md` |
| 7 | `chrysalis-07-report` | Summary for the human + manual-test checklist + next component | `.claude/chrysalis/changes/<slug>/FINAL_REPORT.md`, `.claude/chrysalis/docs/<slug>.md` |

## How to run it

Just ask Claude Code for a specific phase, for example:

> "Run chrysalis-01-project-analyzer on this project"

> "Run chrysalis-02-component-analyzer on UserProfileCard.vue"

Each skill will tell you when it's done and what to do next — you decide whether to move on or stop and take a look yourself.
