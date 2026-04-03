# 008. Project-Scoped Instruction Discovery for /pro Commands

Date: 2026-03-26

## Status

Accepted

## Context

Some `/pro:*` commands (notably refactor-style workflows) may attempt to "find"
instruction files like `AGENTS.md` and `CLAUDE.md`. If implemented naively, this
can lead to expensive and incorrect searches outside the project root (e.g.
globbing `$HOME/**/CLAUDE.md`).

This has two problems:

1. Performance and UX: large filesystem scans are slow and noisy.
2. Correctness and safety: searching outside the repo can pull in unrelated
   instructions from other projects or global config, changing behavior in
   surprising ways.

## Decision

When `/pro:*` commands need to consult instruction files, they must only
consider instruction files that are inside the current project's root
directory.

Project root resolution:

- If inside a git repository: use `git rev-parse --show-toplevel`
- Otherwise: use the current working directory

Project-scoped instruction discovery (in order):

1. `AGENTS.md`
2. `CLAUDE.md`
3. `.claude/CLAUDE.md`
4. `doc/decisions/*` and `doc/rules/*` (if present)

Commands must not glob or search outside the project directory for
`AGENTS.md`/`CLAUDE.md`.

## Consequences

- ✅ Commands behave consistently per-repo and avoid cross-project leakage.
- ✅ Eliminates slow, noisy `$HOME`-wide searches.
- ✅ Encourages durable, project-local guidance (`doc/rules/*`, ADRs) over global
  instruction bloat.
- ⚠️ A contributor relying on a global `AGENTS.md`/`CLAUDE.md` will not have that
  file explicitly "checked" by the command's discovery logic.

## Alternatives Considered

1. **Search globally and prefer nearest match** – rejected due to performance
   hazards and cross-project leakage.
2. **Hardcode global config paths** – rejected because it assumes a single user
   environment and undermines portability.

## Related

- Planning: `doc/.plan/.done/feat-port-pro-backlog-spec-spike/`
