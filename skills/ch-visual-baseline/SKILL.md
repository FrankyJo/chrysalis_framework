---
name: ch-visual-baseline
description: Phase 4 of Chrysalis. Detects whether the Playwright MCP server is available, offers to install it if missing, and captures baseline screenshots of every visual state of a component BEFORE refactoring so a later visual diff can catch UI regressions. Use after ch-test-baseline completes, when the user says "take screenshots before refactoring", "set up Playwright", "capture the component's visual state", or continues Chrysalis pipeline. Also use this skill any time the user asks whether Playwright MCP is installed or wants to set it up, even outside the refactor pipeline.
---

# Phase 4: Visual Baseline (+ Playwright MCP setup)

You are executing the FOURTH phase — capturing screenshots of ALL of the component's states BEFORE the refactor, so that later (phase 6) a "before/after" comparison can catch visual regressions that unit tests can't see.

## Which component this runs on

- If invoked with an argument (a filename/path), use that component, overriding the session state below.
- Otherwise, read `.claude/chrysalis/state.json` and use its `current_component` / `current_component_path`. If the file doesn't exist or has no `current_component`, stop and tell the user to run `ch-component-analyzer <component>` first.
- State which component you're operating on before doing anything else.
- When this phase finishes (including if the visual check is skipped), update `.claude/chrysalis/state.json`: set `last_phase_completed` to `4`.

## Step 1. Check whether Playwright MCP is connected

Run `scripts/check_playwright.sh` (bash). Three possible outcomes:

- **exit 0 (configured and connected)** → go straight to step 2.
- **exit 2 (configured but not connected)** → tell the user the server is registered but unreachable (they may need to check `claude mcp list` for error details — auth/failed/pending approval), offer to troubleshoot together or skip this phase as in the "not installed" scenario below.
- **exit 1 (not found)** → go to the "Playwright MCP not installed" step below.

## Step 1a. If Playwright MCP is not installed

Briefly explain to the user: without Playwright MCP you can still keep refactoring, but you won't be able to automatically compare "before/after" screenshots — visual regressions (shifted layout, a missing icon, broken responsiveness) will have to be caught manually. Offer three options:

1. **Install now automatically** — run these in order (ask for confirmation before running, since this changes the user's system):
   ```bash
   npx playwright install
   claude mcp add --scope project playwright -- npx -y @playwright/mcp@latest
   ```
   The first command downloads browser binaries (Chromium/Firefox/WebKit), the second registers the MCP server in the project (`.mcp.json`). After that, rerun the check (`check_playwright.sh`) — if it now exits 0, continue with step 2.

2. **Install manually per the official docs** — provide the link: https://playwright.dev/docs/getting-started-mcp — and offer to come back to this phase once it's ready.

3. **Skip the visual check** — if the user declines to install, that's fine, the framework still works. Create the file `.claude/chrysalis/changes/<component-slug>/VISUAL_BASELINE_SKIPPED.md`:
   ```markdown
   # Visual baseline skipped

   Playwright MCP was not installed at the time this component was refactored.
   The automated "before/after" screenshot comparison (phase 6) will be skipped.
   **Visual regressions need to be checked manually** during the manual test pass (phase 7).
   ```
   Then go straight to the summary and stop (skip steps 2 and 3).

## Step 2. Identify the component's states

Based on `.claude/chrysalis/changes/<component-slug>/ANALYSIS.md` from phase 2, list all the states worth capturing:
- loading / successfully loaded with data / empty state / error state;
- key prop/input variations (e.g. with and without an icon, different user roles, different languages if there's i18n-dependent markup);
- interactive states, if they matter (an open modal, an expanded dropdown, hover/focus if it affects layout);
- 2-3 viewport sizes if the component is responsive (e.g. 375px, 768px, 1440px).

Don't try to capture absolutely everything — focus on states that could realistically break when the internal structure is refactored.

## Step 3. Capture screenshots via Playwright MCP

For each identified state: open/set up the needed state in the browser via Playwright MCP tools, take a screenshot, save it to `.claude/chrysalis/changes/<component-slug>/visual-baseline/<state-name>.png`. Create `.claude/chrysalis/changes/<component-slug>/visual-baseline/manifest.json` listing `{state, screenshot, viewport, notes}` — phase 6 will need this for comparison.

## Stop

Give a summary: how many states were captured (or why it was skipped, with a clear reminder of the risk). Ask for confirmation to continue:

> "The visual baseline is ready (or: skipped — see the warning above). Ready to start the actual refactor via `ch-execute` whenever you say so — it'll pick up this component automatically."

Do not start the next phase yourself.
