# config-opencode

Local development workspace for translating Claude Code plugin artifacts into OpenCode-compatible configuration.

Research notes for the Claude Code -> OpenCode extension mapping are documented in
`doc/research/claude-code-to-opencode-extension-port.md`.

## Command + plugin install

All `/pro:` command sources live in `opencode/pro/commands/`. The `Makefile`
auto-discovers every `*.md` file in that directory and symlinks it into the
global OpenCode colon namespace (e.g., `pro:feature`, `pro:session.handoff`).

- Install everything (commands + plugins):
  ```bash
  make install
  ```
- Commands only (auto-detected list):
  ```bash
  make install-commands
  ```
- Plugins only:
  ```bash
  make install-plugins
  ```

## Plan-by-default safety rail

This repo ships a global OpenCode plugin that reduces the most common Plan/Build
footgun:

- You switch to `build` to execute changes.
- You forget you are still in `build`.
- You send the next prompt expecting `plan` behavior.
- The agent starts editing/running immediately.

### What it does

When a user prompt is issued under the `build` primary agent, the plugin
automatically switches the UI back to `plan` immediately after the prompt is
submitted. This makes Plan the sticky default for the next prompt.

Source: `opencode/pro/plugins/auto-return-to-plan.js`

Optional: disable the toast via `OPENCODE_AUTO_RETURN_TO_PLAN_TOAST=0`.

### Install

```bash
make install
```

This symlinks the plugin into `~/.config/opencode/plugins/` so OpenCode loads it
automatically on startup.

### Optional hardening (automated)

The plugin works without any changes to `~/.config/opencode/opencode.json`.

If you want additional guardrails, run:

```bash
make enable-plan-safety
```

This updates your global OpenCode config with a timestamped backup:

- sets `default_agent: "plan"` (new sessions start in Plan)
- sets Build permissions to require confirmation:
  - `agent.build.permission.edit: "ask"`
  - `agent.build.permission.bash: "ask"`

Dry-run:

```bash
ENABLE_PLAN_SAFETY_DRY_RUN=1 make enable-plan-safety
```

Note: the updater normalizes `opencode.json` to standard JSON (comments removed).
The original file is preserved in the backup.

### Known limitation

Until OpenCode supports deterministic agent switching (e.g. `tui.agent.set`),
the plugin uses the built-in `agent.cycle` command. This is deterministic for
the default two-primary-agent setup (Build/Plan), but may not land on Plan if
you add additional primary agents.

Upstream:

- https://github.com/anomalyco/opencode/issues/14528
- https://github.com/anomalyco/opencode/issues/14882
- Inspect current symlink state and detected command set:
  ```bash
  make status
  ```
- Remove all links that `make install` created:
  ```bash
  make uninstall
  ```

Slash namespaces are no longer supported—the colon namespace now updates
automatically whenever new command markdown files are added.

## Clipboard helpers

- `/pro:copy.questions` copies recent clarifying questions to your clipboard.
- `/pro:copy.last.response` copies the most recent assistant response to your clipboard.

## Rules toolkit

This repo also ships a `/rules:*` command namespace for creating and maintaining durable, explainable rules without bloating `AGENTS.md`:

- `/rules:where` decide where a rule should live (command vs plugin vs ADR vs docs)
- `/rules:propose` run a planning conversation and output an Apply Pack (no writes)
- `/rules:apply` apply the latest Apply Pack (writes)
- `/rules:why` trace provenance for "why does this rule exist?"
- `/rules:stale` find rules that are past ReviewBy

## Optional: install toolkit AGENTS.md

This is intentionally opt-in. To symlink the toolkit's minimal constitution rules to your global OpenCode config:

```bash
make install-agents
```

To remove the symlink:

```bash
make uninstall-agents
```

## Session handoff workflow

Running `make install` links `opencode/pro/plugins/session-handoff.js`, which
captures git/backlog metadata on key lifecycle events. Each snapshot is stored as
its own file under `doc/.plan/session-handoff/sessions/`, indexed by
`doc/.plan/session-handoff/index.json`, and summarized in the ledger
`doc/.plan/session-handoff.md`.

A companion CLI manages the workflow (installed to `~/.config/opencode/bin/session-handoff.mjs` by `make install`). Run it from the client project root:

```bash
# Show pending snapshots (add --all for history)
node "$HOME/.config/opencode/bin/session-handoff.mjs" list

# Capture a fresh snapshot for the current repo state
node "$HOME/.config/opencode/bin/session-handoff.mjs" write --trigger "/pro:session.handoff"

# Close out finished work with an optional note
node "$HOME/.config/opencode/bin/session-handoff.mjs" ack <snapshot-id> --note "wrapped up the fix"

# Dismiss stale entries that should not block future sessions
node "$HOME/.config/opencode/bin/session-handoff.mjs" dismiss <snapshot-id> --reason "obsolete task"

If you vendor the CLI into a repo instead, you can run:

```bash
node bin/session-handoff.mjs list|ack|dismiss|write ...
```
```

Before ending a session:

1. Run `node "$HOME/.config/opencode/bin/session-handoff.mjs" list` to review outstanding snapshot IDs.
2. Open the referenced files under `doc/.plan/session-handoff/sessions/` and finish
   or dismiss each checklist via the CLI.
3. Run `node "$HOME/.config/opencode/bin/session-handoff.mjs" write --trigger "/pro:session.handoff"` to
   capture the latest context. The ledger at `doc/.plan/session-handoff.md` should
   now show accurate `Outstanding Snapshots` and recent activity.

This workflow keeps the shared ledger trustworthy and gives every OpenCode
session a deterministic handoff path.
