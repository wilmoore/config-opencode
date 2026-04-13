---
description: "Ending a session? Refresh `doc/.plan/session-handoff.md` and confirm the snapshot is current before you leave"
agent: build
---

## Context

The session handoff plugin now writes one snapshot per session under
`doc/.plan/session-handoff/sessions/` and tracks their status in
`doc/.plan/session-handoff/index.json`. The shared ledger
`doc/.plan/session-handoff.md` summarizes what is outstanding.

Use the helper CLI (installed by this toolkit to `~/.config/opencode/bin/`) to
review, acknowledge, dismiss, or create snapshots so the next session knows
exactly what happened.

## Your Task

### Step 1: Inspect outstanding snapshots

1. List pending entries:
   ```bash
    node "$HOME/.config/opencode/bin/session-handoff.mjs" list
   ```
2. For each pending `id`, open the referenced file (path shown in the list) and
   follow the checklist it contains.

### Step 2: Close or dismiss what you reviewed

- Mark a snapshot complete when everything in the file is satisfied:
  ```bash
  node "$HOME/.config/opencode/bin/session-handoff.mjs" ack <snapshot-id> --note "what changed"
  ```

  Vendored alternative (if `bin/session-handoff.mjs` exists in this repo):
  ```bash
  node bin/session-handoff.mjs ack <snapshot-id> --note "what changed"
  ```
- If the work is no longer relevant, dismiss it instead:
  ```bash
  node "$HOME/.config/opencode/bin/session-handoff.mjs" dismiss <snapshot-id> --reason "why it's safe"
  ```

  Vendored alternative:
  ```bash
  node bin/session-handoff.mjs dismiss <snapshot-id> --reason "why it's safe"
  ```

### Step 3: Capture a fresh handoff for this session

1. Refresh your repo context (commit status, backlog summary, etc.).
2. Write a new snapshot so the ledger reflects your current state:
   ```bash
    node "$HOME/.config/opencode/bin/session-handoff.mjs" write --trigger "/pro:session.handoff"
   ```
3. Optionally rerun `node "$HOME/.config/opencode/bin/session-handoff.mjs" list --all` to confirm the new
    entry is present and any previous ones moved to `acknowledged` or
    `dismissed`.

### Step 4: Verify the ledger

1. Open `doc/.plan/session-handoff.md` to confirm:
   - `Outstanding Snapshots` only lists the entries you expect to leave behind.
   - Your new snapshot appears with status `pending`.
2. If the ledger looks outdated, rerun the CLI commands above until it reflects
   reality. The next session will rely on these files when `opencode` starts.
