# 010. Install Session Handoff CLI Globally and Reference It in Ledgers

Date: 2026-04-07

## Status

Accepted

## Context

Session handoff ledgers and snapshot files include copy/pasteable next steps.
Historically, those steps referenced:

- `node bin/session-handoff.mjs ...`

That assumes each project contains a `bin/session-handoff.mjs` file. In this
toolkit, the CLI lives in the `config-opencode` repository, and users typically
install commands/plugins globally into `~/.config/opencode` to use them across
many projects.

When running session handoff in a client project, the ledger instructions were
incorrect (the project's `bin/` directory often does not include the CLI), which
created confusing assistant commentary and broken next-step instructions.

## Decision

1. Install the session handoff CLI as part of the default toolkit install:

- Create a symlink at:
  - `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/bin/session-handoff.mjs`
- That points to the toolkit repository file:
  - `<toolkit-repo>/bin/session-handoff.mjs`

2. Update session-handoff ledger and command text to reference the globally
installed CLI path (and to note it should be run from the client project root).

## Consequences

- ✅ Ledger instructions work in any project after running `make install` in the
  toolkit repo.
- ✅ Removes an implicit dependency on per-project `bin/` contents.
- ✅ Keeps ADR-003 intent (ship a CLI) while aligning with the global install
  model.
- ⚠️ Requires maintaining the Makefile CLI install target and keeping the ledger
  strings in sync.

## Alternatives Considered

1. **Keep `node bin/session-handoff.mjs ...` and document "run it from the
   toolkit repo"** – rejected because it is easy to misapply in client repos.
2. **Remove the CLI and only use OpenCode commands** – rejected because ADR-003
   explicitly calls for a companion CLI and a deterministic non-LLM workflow.

## Related

- ADR-003: `doc/decisions/003-adopt-per-session-handoff-ledger.md`
- Planning: `doc/.plan/.done/fix-session-handoff-cli-reference/` (after merge)
