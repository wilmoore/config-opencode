# Plan-by-default Safety Rail

## Why this exists

OpenCode’s `plan` primary agent is a great safety rail for analysis-only work.
The practical workflow problem is that we must temporarily switch to `build` to
execute changes.

The footgun:

1. Switch to `build` to implement.
2. Complete the change.
3. Forget you are still in `build`.
4. Send the next prompt expecting `plan`.
5. The agent starts editing files / running commands immediately.

This repo implements a guardrail so Plan becomes the sticky default again.

## What we ship

### 1) A global plugin: auto-return to Plan

Source: `opencode/pro/plugins/auto-return-to-plan.js`

Behavior:

- listens for `message.updated`
- when the event is a **user message** created under `agent: "build"`, it runs:
  - `tui.executeCommand("agent.cycle")`
- shows an informational toast so the mode change is visible

Optional:

- set `OPENCODE_AUTO_RETURN_TO_PLAN_TOAST=0` to disable the toast

Notes:

- This is best-effort: in non-TUI contexts (e.g. `opencode run`), TUI calls may
  be unavailable; the plugin will not error.
- We dedupe per message id to avoid repeated switching if the event fires more
  than once.

### 2) An explicit setup command: enable Plan safety rails

Target: `make enable-plan-safety`

This is intentionally separate from install.

- `make install` only links commands/plugins.
- `make enable-plan-safety` explicitly edits global OpenCode config.

Script: `bin/enable-plan-safety.mjs`

Changes applied:

- `default_agent: "plan"`
- `agent.build.permission.edit: "ask"`
- `agent.build.permission.bash: "ask"` (or ensures `"*": "ask"` for object form)

Safety:

- creates a timestamped backup of the prior `~/.config/opencode/opencode.json`
- supports dry-run with `ENABLE_PLAN_SAFETY_DRY_RUN=1`
- normalizes the written config to standard JSON (comments removed); the backup
  preserves the original

## Relationship to upstream

This plugin relies on `agent.cycle`, which is deterministic only when the
primary agent list is effectively `build <-> plan`.

If/when upstream exposes deterministic switching by name (e.g. `tui.agent.set`
or an SDK method), this plugin can be updated to be robust even with multiple
custom primary agents.

Upstream references:

- https://github.com/anomalyco/opencode/issues/14528
- https://github.com/anomalyco/opencode/issues/14882
