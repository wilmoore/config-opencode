# Plan: Port Audit, Quality-Gate, and Product Commands

## Goal

Port the remaining ccplugins `/pro:*` commands for audit, quality, and product workflows into OpenCode-native configuration.

## Selected Backlog Items

| ID | Title | Description |
|----|-------|-------------|
| #11 | Harden auto-return-to-plan | Depends on upstream OpenCode API - evaluate feasibility |
| #17 | Port /pro:audit* commands | audit.md, audit.quality.md, audit.repo.md, audit.security.md |
| #18 | Port /pro:quality-gate + dev.setup | Plus templates/_bins asset strategy |
| #20 | Port /pro:product.validate + pitch | Product validation workflow |

## Constraints

- `doc/decisions/005-standardize-plan-root.md`: all planning artifacts live under `doc/.plan/`
- `doc/decisions/007-add-rules-toolkit-and-opt-in-agents-install.md`: prefer `/rules:*` over legacy `/pro:rules*`
- Follow existing `opencode/pro/commands/*` authoring style

## Work Plan

### Phase 1: Evaluate #11 (Harden auto-return-to-plan)

- [x] Check current OpenCode plugin API capabilities
- [x] Determine if `tui.agent.set { name }` or equivalent exists

**Finding:** OpenCode TUI does not currently expose a deterministic agent-switching API.

- Current plugin uses `agent.cycle` which cycles through agents
- No `tui.agent.set { name }` or equivalent method available
- The TUI LocalProvider manages agent state internally but doesn't expose direct setting

**Decision:** Mark #11 as **blocked on upstream**. The current `agent.cycle` approach works correctly for the default two-agent setup (Build/Plan). When OpenCode exposes a deterministic agent API, this can be revisited.

**Action:** Update backlog status to "open" with a note about upstream dependency.

### Phase 2: Port Audit Commands (#17)

- [x] Read `_tmp_ccplugins/pro/commands/audit.md`
- [x] Read `_tmp_ccplugins/pro/commands/audit.quality.md`
- [x] Read `_tmp_ccplugins/pro/commands/audit.repo.md`
- [x] Read `_tmp_ccplugins/pro/commands/audit.security.md`
- [x] Port each to `opencode/pro/commands/`
- [x] Ensure backlog output targets `doc/.plan/backlog.json`

**Ported files:**
- `opencode/pro/commands/audit.md`
- `opencode/pro/commands/audit.quality.md`
- `opencode/pro/commands/audit.repo.md`
- `opencode/pro/commands/audit.security.md`

### Phase 3: Port Quality-Gate and Dev.Setup (#18)

- [x] Read `_tmp_ccplugins/pro/commands/quality-gate.md`
- [x] Read `_tmp_ccplugins/pro/commands/dev.setup.md`
- [x] Analyze `_tmp_ccplugins/pro/commands/_templates/*` dependencies
- [x] Analyze `_tmp_ccplugins/pro/commands/_bins/*` dependencies
- [x] Decide asset strategy (inline vs. separate dir vs. skip)
- [x] Port commands with asset references resolved

**Asset Strategy Decision:**
- Created `opencode/pro/commands/_templates/quality-gate/` for CI workflow and lint-staged templates
- Created `opencode/pro/commands/_bins/dev/` for dev.ts, notify.ts, and README.template.md
- Updated command path references to use OpenCode directory structure

**Ported files:**
- `opencode/pro/commands/quality-gate.md`
- `opencode/pro/commands/dev.setup.md`
- `opencode/pro/commands/_templates/quality-gate/*.hbs` (CI templates)
- `opencode/pro/commands/_templates/quality-gate/*.json` (lint-staged configs)
- `opencode/pro/commands/_bins/dev/*` (dev CLI scripts and docs)

### Phase 4: Port Product Commands (#20)

- [x] Read `_tmp_ccplugins/pro/commands/product.validate.md`
- [x] Read `_tmp_ccplugins/pro/commands/product.pitch.md`
- [x] Port each to `opencode/pro/commands/`
- [x] Verify compatibility with existing `/pro:product.brief`

**Compatibility notes:**
- Updated `.plan/product/` paths to `doc/.plan/product/` to match existing product.brief.md
- Consistent with ADR-005 (doc/.plan/ is the planning root)

**Ported files:**
- `opencode/pro/commands/product.validate.md`
- `opencode/pro/commands/product.pitch.md`

## Summary

All phases complete:
- Phase 1: #11 blocked on upstream (no tui.agent.set API)
- Phase 2: #17 complete - 4 audit commands ported
- Phase 3: #18 complete - quality-gate + dev.setup with assets
- Phase 4: #20 complete - product.validate + product.pitch

## Notes

- This is a batch of related porting work
- Item #11 is blocked on upstream OpenCode features (needs tui.agent.set)

## Related ADRs

- `doc/decisions/011-co-locate-command-support-assets-with-ported-pro-commands.md`
- `doc/decisions/012-treat-deterministic-agent-switching-as-an-upstream-dependency.md`
