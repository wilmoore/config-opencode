# 006. Add Plan-by-default Safety Rail

Date: 2026-03-08

## Status

Accepted

## Context

Plan mode is the intended safety rail for planning and analysis. In practice,
contributors must temporarily switch to Build mode to execute changes.

The footgun is common and costly: after exiting Plan, it is easy to forget the
active agent is still Build, issue the next prompt expecting Plan behavior, and
have the agent start editing files or running commands immediately.

Additionally, plugins or commands that rely on user-specific global OpenCode
configuration must not silently fail. If global configuration is required, we
need an explicit, intention-revealing setup step.

## Decision

Ship a "Plan-by-default" safety rail with two layers:

1. **Runtime guardrail (no config required)**
   - Provide a global OpenCode plugin that automatically returns the active
     primary agent to Plan after any user prompt issued under Build.
   - The plugin should be best-effort and must not error in non-TUI contexts.

2. **Optional config hardening (explicit automation)**
   - Provide a dedicated Makefile target that explicitly updates the user's
     global OpenCode config (with backups) to:
     - set `default_agent: "plan"`
     - require confirmation for Build edits and shell commands

## Consequences

- ✅ The default workflow becomes safer: after using Build, the next prompt is
  Plan unless the user explicitly switches again.
- ✅ The plugin works even if the user never touches their global config.
- ✅ When global config changes are desired, they are applied intentionally,
  with backups and a dry-run option.
- ⚠️ The plugin currently relies on the built-in `agent.cycle` TUI command, which
  is deterministic only for the default two-primary-agent setup (Build/Plan).
  A future upstream `tui.agent.set { name }` would remove this limitation.
- ⚠️ The config updater normalizes JSONC to standard JSON; a backup preserves the
  original file.

## Alternatives Considered

1. **Rely on documentation only** - rejected because the failure mode is common
   and happens precisely when users forget a manual step.
2. **Enforce Plan-only by disabling Build tools** - rejected because Build is
   necessary for implementation work.
3. **Always cycle agents after every prompt** - rejected because it would be
   surprising and interfere with intentional workflows.

## Related

- Planning: `doc/.plan/.done/feat-force-plan-mode-default/`
- Upstream: https://github.com/anomalyco/opencode/issues/14528
- Upstream: https://github.com/anomalyco/opencode/issues/14882
