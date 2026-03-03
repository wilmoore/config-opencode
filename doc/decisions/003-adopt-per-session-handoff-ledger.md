# 003. Adopt Per-Session Handoff Ledger and CLI

Date: 2026-03-03

## Status

Accepted

## Context

The original session-handoff approach overwrote a single
`.plan/session-handoff.md` file on every lifecycle event. That meant a new
OpenCode session immediately erased the snapshot left by the previous author,
so the checklist was often lost before anyone could act on it. The install
automation also required manually updating a fixed list of command filenames,
making it easy to forget newly ported `/pro:` workflows.

## Decision

Store each session snapshot as its own markdown file under
`.plan/session-handoff/sessions/` and maintain an index/ledger that tracks
whether each entry is pending, acknowledged, or dismissed. Ship a companion
CLI (`bin/session-handoff.mjs`) and plugin updates that:

1. Prompt once per session about outstanding snapshots.
2. Auto-write a new snapshot file with current git/backlog metadata.
3. Let contributors list, acknowledge, dismiss, or manually write snapshots.
4. Keep a concise ledger in `.plan/session-handoff.md` for at-a-glance status.

In parallel, update the Makefile installer to discover every
`opencode/pro/commands/*.md` file automatically and drop the unused slash
namespace, so colon-style commands remain in sync without manual edits.

## Consequences

- ✅ Previous session context persists until explicitly acknowledged or
  dismissed, so no one loses instructions when a new session starts.
- ✅ Contributors have a deterministic CLI workflow plus plugin prompts to keep
  the ledger accurate.
- ✅ Command installs stay aligned with the real file set, reducing maintenance
  toil when new `/pro:` commands are ported.
- ⚠️ `.plan/session-handoff/` accumulates more files; periodic cleanup or
  archival may be needed.
- ⚠️ The CLI and plugin introduce additional code paths that must stay in sync
  with OpenCode releases.

## Alternatives Considered

1. **Keep a single shared file** – rejected because it overwrote previous
   checklists before anyone could act.
2. **Rely solely on manual `/pro:session.handoff` command** – rejected because
   humans frequently forget to run it; the plugin+CLI combo enforces prompts and
   automation.
3. **Track snapshots only in JSON** – rejected to preserve human-readable
   markdown instructions per session.

## Related

- Planning: `.plan/.done/feat-session-handoff-snapshots/`
