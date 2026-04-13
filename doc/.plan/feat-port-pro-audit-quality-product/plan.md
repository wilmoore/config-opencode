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

- [ ] Read `_tmp_ccplugins/pro/commands/quality-gate.md`
- [ ] Read `_tmp_ccplugins/pro/commands/dev.setup.md`
- [ ] Analyze `_tmp_ccplugins/pro/commands/_templates/*` dependencies
- [ ] Analyze `_tmp_ccplugins/pro/commands/_bins/*` dependencies
- [ ] Decide asset strategy (inline vs. separate dir vs. skip)
- [ ] Port commands with asset references resolved

### Phase 4: Port Product Commands (#20)

- [ ] Read `_tmp_ccplugins/pro/commands/product.validate.md`
- [ ] Read `_tmp_ccplugins/pro/commands/product.pitch.md`
- [ ] Port each to `opencode/pro/commands/`
- [ ] Verify compatibility with existing `/pro:product.brief`

## Notes

- This is a batch of related porting work
- Item #11 may be blocked on upstream OpenCode features
