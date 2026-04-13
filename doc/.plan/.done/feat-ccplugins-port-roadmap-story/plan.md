# Plan: ccplugins Port Roadmap Story

## Goal

Make the backlog the source of truth for the remaining ccplugins port so a new session can resume without re-research.

This branch also introduces an OpenCode-only clipboard helper command:

- `/pro:copy.last.response` (copy the most recent assistant response to clipboard)

## ADR Constraints (Repo)

- `doc/decisions/001-split-install-targets.md`: keep Makefile install targets split between commands and plugins.
- `doc/decisions/005-standardize-plan-root.md`: canonical planning root is `doc/.plan/`.
- `doc/decisions/006-plan-by-default-safety-rail.md`: preserve safety rails; no hidden global config changes.

## Scope

Single unified sequential roadmap:

1. Remaining `/pro:*` ports (excluding `bip.*`, dropping build-in-public automation)
2. `/author:*` ports
3. `/clip:*` ports (as OpenCode commands; not skills)
4. Non-command parity work (MCP config, hooks, templates/bin assets, skills evaluation)

## Port Order (Locked)

`/pro:*` ports (remaining):

1. `spec.md`, `spec.import.md`
2. `backlog.md`, `backlog.add.md`, `backlog.resume.md`, `backlog.mvp.md`
3. `spike.md`
4. `onboarding.md`
5. evaluate the new ccplugins `/pro:evaluate.framework` workflow and port it into the best OpenCode-native surface
6. `audit.md`, `audit.quality.md`, `audit.repo.md`, `audit.security.md`
7. `quality-gate.md`, `dev.setup.md` (plus templates/_bins strategy)
8. `branch.park.md`, `branch.rmrf.md`, `handoff.md`, `git.main.md`, `roadmap.md`
9. `product.pitch.md`, `product.validate.md`
10. long tail (including `social.md`, `og.md`; excluding `bip.md`, `bip.setup.md`)

`/rules:*` toolkit:

- Implement `/rules:*` commands as toolkit-native (skip porting legacy `/pro:rules*`).

`/author:*` ports:

- `_tmp_ccplugins/author/commands/*`

`/clip:*` ports:

- Implement as OpenCode commands.
- `/clip:content.screenshot` must copy an actual image to clipboard cross-platform when possible, with fallback to copying a file path.

## Story Artifacts

- Backlog: `doc/.plan/backlog.json` contains the epic and per-batch items.
- Brief/PRD: `doc/.plan/product/briefs/2026-03-08-ccplugins-port-roadmap.md` documents scope, constraints, and roadmap.

## Definition of Done

- Backlog updated with epic + ordered batches.
- PRD/brief file exists and links to roadmap decisions.
- `/pro:copy.last.response` command exists under `opencode/pro/commands/`.

## Related ADRs

- [007. Add /rules Toolkit Commands and Opt-in AGENTS Install](../../decisions/007-add-rules-toolkit-and-opt-in-agents-install.md)
