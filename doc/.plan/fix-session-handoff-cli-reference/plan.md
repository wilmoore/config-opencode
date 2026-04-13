# Plan: Fix Session Handoff CLI Reference Mismatch

Branch: `fix/session-handoff-cli-reference`

## ADRs Considered

- `doc/decisions/003-adopt-per-session-handoff-ledger.md` (expects a companion CLI: `bin/session-handoff.mjs`)
- `doc/decisions/004-maintain-session-handoff-metadata.md` (CLI + markdown snapshots must remain consistent)
- `doc/decisions/005-standardize-plan-root.md` (plan artifacts under `doc/.plan/`)

## Related ADRs

- [010. Install Session Handoff CLI Globally and Reference It in Ledgers](../../decisions/010-install-session-handoff-cli-globally-and-reference-it-in-ledgers.md)

## Problem

Session-handoff output/ledger references a CLI invocation `node bin/session-handoff.mjs ...`, but the user observed that the CLI does not exist in this repo (or is not installed), making the suggested next steps incorrect.

## Goal

- Ensure the session-handoff ledger and any assistant commentary reference a real, present CLI command path (or update the docs to match the actual path).
- Keep behavior aligned with ADR-003/004 expectations.

## Approach

1. Capture repro steps + expected/actual behavior.
2. Inspect repo for the CLI (`bin/session-handoff.mjs`) and any alternate location.
3. Decide:
   - restore/add the CLI at `bin/session-handoff.mjs`, OR
   - update ledger text to point to the correct existing CLI.
4. Verify by generating a new session-handoff snapshot and confirming the ledger's instructions are accurate.
