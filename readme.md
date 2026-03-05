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
- Plugins only (currently the session handoff helper):
  ```bash
  make install-plugins
  ```
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

## Session handoff workflow

Running `make install` links `opencode/pro/plugins/session-handoff.js`, which
captures git/backlog metadata on key lifecycle events. Each snapshot is stored as
its own file under `doc/.plan/session-handoff/sessions/`, indexed by
`doc/.plan/session-handoff/index.json`, and summarized in the ledger
`doc/.plan/session-handoff.md`.

A companion CLI at `bin/session-handoff.mjs` manages the workflow:

```bash
# Show pending snapshots (add --all for history)
node bin/session-handoff.mjs list

# Capture a fresh snapshot for the current repo state
node bin/session-handoff.mjs write --trigger "/pro:session.handoff"

# Close out finished work with an optional note
node bin/session-handoff.mjs ack <snapshot-id> --note "wrapped up the fix"

# Dismiss stale entries that should not block future sessions
node bin/session-handoff.mjs dismiss <snapshot-id> --reason "obsolete task"
```

Before ending a session:

1. Run `node bin/session-handoff.mjs list` to review outstanding snapshot IDs.
2. Open the referenced files under `doc/.plan/session-handoff/sessions/` and finish
   or dismiss each checklist via the CLI.
3. Run `node bin/session-handoff.mjs write --trigger "/pro:session.handoff"` to
   capture the latest context. The ledger at `doc/.plan/session-handoff.md` should
   now show accurate `Outstanding Snapshots` and recent activity.

This workflow keeps the shared ledger trustworthy and gives every OpenCode
session a deterministic handoff path.
