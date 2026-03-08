# Plan-By-Default Safety Rail

## Problem

Plan mode is the intended safety rail for analysis-only work. In practice, we must
temporarily switch to Build to execute changes. The footgun: after leaving Plan,
it is easy to forget we are still in Build, issue a new prompt expecting Plan,
and accidentally start editing files or running commands.

## Goals

- After any user prompt issued while the active primary agent is `build`, the UI
  should immediately return to `plan` so the next prompt is safe-by-default.
- Avoid silent dependencies on user config. Installing plugins/commands must not
  require manual edits to `~/.config/opencode/opencode.json`.
- If optional config hardening is desired, it must be applied via an explicit,
  intention-revealing automation step.

## Approach

1. Install-time behavior:
   - Ship a global OpenCode plugin (symlinked into `~/.config/opencode/plugins/`)
     that listens for `message.updated` events.
   - When a user message is sent under agent `build`, trigger a best-effort TUI
     command `agent.cycle` to return to Plan.
   - Show a toast so the user notices the mode change.

2. Optional config hardening (explicit):
   - Provide `make enable-plan-safety` which edits global OpenCode config to:
     - set `default_agent: "plan"`
     - set `agent.build.permission.edit: "ask"`
     - set `agent.build.permission.bash: "ask"` (or add `"*": "ask"` for object form)
   - Must be idempotent.
   - Must create a timestamped backup before writing.
   - Must support dry-run.

## Known Limitations

- Until upstream supports deterministic agent switching (e.g. `tui.agent.set`),
  the local plugin relies on `agent.cycle`. This is deterministic for the
  default two-primary-agent setup (Build/Plan) but not for custom primary agent
  sequences.

Upstream:
- https://github.com/anomalyco/opencode/issues/14528
- https://github.com/anomalyco/opencode/issues/14882

## Implementation Steps

- Add `opencode/pro/plugins/auto-return-to-plan.js`.
- Fix Makefile install to actually install plugins (ADR-001).
- Add `bin/enable-plan-safety.mjs` + `make enable-plan-safety`.
- Add repo-level docs (README + dedicated doc page).
- Add minimal tests for JSONC parsing + event gating logic.
- Run `coderabbit --prompt-only`.

## Related ADRs

- `doc/decisions/006-plan-by-default-safety-rail.md`
