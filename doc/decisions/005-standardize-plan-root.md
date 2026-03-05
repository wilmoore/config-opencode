# 005. Standardize Planning Root at doc/.plan

Date: 2026-03-05

## Status

Accepted

## Context

The project had planning artifacts scattered under `.plan/` at the repo root, but documentation lives under `doc/`. Keeping planning artifacts in a dedicated subdirectory of `doc/` groups related project documentation together and makes the planning root more discoverable for contributors.

## Decision

Standardize the planning root at `doc/.plan/`:

- Canonical path: `doc/.plan/`
- Compatibility window: tooling reads from both `doc/.plan/` (preferred) and `.plan/` (legacy), but writes only to `doc/.plan/`
- One-time migration: if `.plan/` exists and `doc/.plan/` is missing, migrate via `git mv`
- If both exist: merge with conflict detection (stop and report conflicts rather than overwrite)

Introduce a shared helper (`opencode/pro/lib/plan-root.mjs`) that handles:
- `read()` / `readJson()` - resolves from canonical first, falls back to legacy
- `write()` / `writeJson()` - always writes to canonical
- `exists()` - checks both locations

## Consequences

- ✅ All planning artifacts now live alongside documentation in `doc/.plan/`
- ✅ Backwards compatibility: existing repos with `.plan/` continue to work
- ✅ Clear migration path: one-time move with conflict detection
- ⚠️ Requires updating all command documentation and code references to use new paths

## Alternatives Considered

1. **Hard cutover to `doc/.plan/`** - rejected because it would break existing repos
2. **Keep both `.plan/` and `doc/.plan/` as separate concerns** - rejected because it creates confusion about which to use

## Related

- Planning: `doc/.plan/.done/feat-make-target-commands/`