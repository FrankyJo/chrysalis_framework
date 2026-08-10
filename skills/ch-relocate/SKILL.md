---
name: ch-relocate
description: Optional phase of Chrysalis, run after ch-verify has returned PASS or WARN, and only when `.claude/chrysalis/module-plan.md` assigns this component to a target module. Physically moves the refactored component (plus the composables/hooks/services and tests extracted for it) to its target module path, rewrites every import across the project that referenced the old path, and gates on a full project build/typecheck. Use when the user says "move this component into its module now", "relocate it", "put it in its module", or continues the Chrysalis pipeline after verify for a component that has a module-plan target. If the component has no module-plan entry, this phase is a no-op — skip straight to ch-report instead.
---

# Optional Phase: Relocate

You are executing the module-relocation step for a component whose internal refactor already passed verification. This is the only phase that moves a component's files across the project and rewrites other files' imports — a different, riskier kind of change than anything in `ch-execute`, which is why it's gated separately with its own build check.

## Which component this runs on

- If invoked with an argument (a filename/path), use that component, overriding the session state below.
- Otherwise, read `.claude/chrysalis/state.json` and use its `current_component` / `current_component_path`. If the file doesn't exist or has no `current_component`, stop and tell the user to run `ch-component-analyzer <component>` first.
- State which component you're operating on before doing anything else.

## Step 0. Check whether this component is even in scope

Read `.claude/chrysalis/module-plan.md`. If the file doesn't exist, or has no row whose "Current path" matches this component's current path: tell the user this component isn't part of a module plan, nothing to relocate, and the next step is `ch-report` directly. Stop here in that case — don't invent a target module.

Also confirm `.claude/chrysalis/changes/<component-slug>/VERIFY_REPORT.md` shows a PASS or WARN verdict from `ch-verify`. If it's missing or shows FAIL, stop and say `ch-verify` needs to pass first — don't relocate code whose refactor isn't verified yet.

## Step 1. Move the files

1. Move the component file itself to the target path from `module-plan.md`.
2. Move any composable/hook/service files that were extracted for it in `ch-execute` (check `.claude/chrysalis/changes/<component-slug>/CHANGES.md` for the list) into the target module, following whatever internal folder convention that module already uses (e.g. `components/`, `composables/`) — or the flat convention the project used before, if the module is new and has no convention yet.
3. Move the component's test files alongside it.
4. Fix the moved component's own relative imports (its relative distance to its dependencies has changed).

## Step 2. Update every call site project-wide

Search the whole project for anything importing the OLD path — relative imports, path-alias imports (e.g. `@/components/ReportForm.vue`), dynamic `import()` calls, and barrel/index re-exports — and rewrite each to the NEW path. If the project uses path aliases (check `vite.config.*` / `jsconfig.json` / `tsconfig.json`), prefer an alias-based import for the new location if that matches the project's existing convention.

## Step 3. Gate on a full build

Run the project's build or typecheck command (from `CLAUDE.md` if it documents one, otherwise the obvious `package.json` script — `build`, `type-check`, etc.). This is the step that catches a missed import that unit tests won't. Also rerun the component's test suite (now at its new path).

- **Both pass** → proceed to Output.
- **Build fails on a missed import** → fix it and rerun the build. This is expected mechanical cleanup, not a design problem.
- **Build fails for a deeper reason** (e.g. a new circular dependency between modules) → stop, do not paper over it, report the specific cycle/error and recommend adjusting `module-plan.md`'s boundaries rather than forcing the move.
- **Tests fail** → same triage as `ch-verify`: real regression from the move (fix it) vs. a test that hardcoded the old path (fix the test).

## Output

`.claude/chrysalis/changes/<component-slug>/RELOCATE_REPORT.md`:

```markdown
# Relocate Report: <component name>

## Moved
Old path: <old path>
New path: <new path>

## Files moved
- <component file>
- <composables/hooks/services moved with it>
- <test files>

## Import call sites updated
<N files>, listed or summarized if there are many

## Build/typecheck
PASS / FAIL

## Tests (post-move)
X/X pass
```

Update `.claude/chrysalis/state.json`: set `current_component_path` to the new path and `relocated` to `true`.

## Stop

Give a summary: new location, how many call sites were updated, build/test result. Ask for confirmation:

> "`<component-slug>` has been relocated to `<new path>`, build and tests pass. Ready to close out with `ch-report` whenever you say so."
