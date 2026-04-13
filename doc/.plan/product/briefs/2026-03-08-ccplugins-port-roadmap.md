# Product Brief

**Working Title:** ccplugins Port Roadmap (OpenCode)
**Created:** 2026-03-08T05:02:46Z

---

## Problem Statement

The legacy Claude Code marketplace package `SavvyAI/ccplugins` contains multiple plugin surfaces (commands, skills, agents, hooks, MCP config) that do not map 1:1 into OpenCode.

We need a durable, backlog-driven roadmap so the port can be continued across sessions without re-research, while preserving the intended command UX (namespaced `/pro:*`, `/author:*`, `/clip:*`).

---

## Proposed Solution

Maintain a single sequential roadmap in `doc/.plan/backlog.json`, anchored by an epic that:

- orders remaining ports (commands first, then author/clip, then infra), while allowing newly added upstream workflows to be pulled forward when they unblock later planning
- records key decisions (dropped items, ordering, portability requirements)
- links to this brief

Implement OpenCode-native commands as Markdown files under `opencode/**/commands/` and install them via scoped symlinks (Makefile) into `~/.config/opencode/commands/`.

---

## Target Customer

### Primary

- Maintainers and contributors porting ccplugins workflows into OpenCode.

### Secondary

- Developers who want consistent guided workflows in OpenCode via namespaced commands.

---

## Why Now?

- The port is mid-stream; without an explicit roadmap + backlog story, sessions regress into re-discovery.
- OpenCode already supports colon-namespaced command filenames, enabling UX parity for `/pro:*`.

---

## Key Assumptions

1. OpenCode command naming remains filename-based and supports colon namespaces.
2. Planning artifacts should be canonical under `doc/.plan/` (per repo ADR).
3. Cross-platform behavior is a requirement, especially for clipboard-centric commands.

---

## Constraints / ADRs

This repo's ADRs that constrain implementation:

- `doc/decisions/001-split-install-targets.md`
- `doc/decisions/005-standardize-plan-root.md`
- `doc/decisions/006-plan-by-default-safety-rail.md`

---

## Roadmap (Sequential)

### A) `/pro:*` commands (remaining)

Order is intentional:

1. `spec.md`, `spec.import.md`
2. `backlog.md`, `backlog.add.md`, `backlog.resume.md`, `backlog.mvp.md`
3. `spike.md`
4. `onboarding.md`
5. evaluate the new ccplugins `/pro:evaluate.framework` workflow and port it into the best OpenCode-native surface
6. `audit.md`, `audit.quality.md`, `audit.repo.md`, `audit.security.md`
7. `quality-gate.md`, `dev.setup.md` (includes templates/_bins decisions)
8. `branch.park.md`, `branch.rmrf.md`, `handoff.md`, `git.main.md`, `roadmap.md`
9. `product.pitch.md`, `product.validate.md`
10. long tail (includes `social.md`, `og.md`; excludes `bip.md`, `bip.setup.md`)

Dropped:

- `bip.md`, `bip.setup.md`
- build-in-public automation (legacy agent/skill) only
- `/pro:rules*` commands (replaced by `/rules:*`)

### A.1) `/rules:*` commands (toolkit)

This port intentionally moves away from relying on `CLAUDE.md`/`AGENTS.md` bloat.

- `/rules:where`
- `/rules:propose`
- `/rules:apply`
- `/rules:why`
- `/rules:stale`

### B) `/author:*` commands

Port `_tmp_ccplugins/author/commands/*` into OpenCode commands and ensure install automation supports the `author:*` namespace.

### C) `/clip:*` commands

Port the intent of `_tmp_ccplugins/clip/skills/*` as OpenCode commands (not skills).

Clipboard behavior requirements:

- `/clip:content.screenshot` copies an actual image cross-platform when possible.
- If image clipboard copy is not available, copy the screenshot file path with a clear message.

### D) Non-command parity

- MCP config: `_tmp_ccplugins/pro/.mcp.json` -> OpenCode `opencode.json` (or documented equivalent)
- Hooks: `_tmp_ccplugins/pro/hooks/*` -> OpenCode plugin behavior or explicit de-scope
- Templates/bin assets: re-home `_tmp_ccplugins/pro/commands/_templates/*` and `_bins/*` and update references
- Remaining skills evaluation (excluding build-in-public): decide which additional items are worth porting in OpenCode after `/pro:evaluate.framework`

---

## Success Criteria

- Backlog contains epic + ordered batch items that match this roadmap.
- A new session can resume port work by reading `doc/.plan/backlog.json` + this brief.
- Namespaced commands remain consistent with OpenCode install strategy.
