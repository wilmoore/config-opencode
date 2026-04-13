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

- [ ] Check current OpenCode plugin API capabilities
- [ ] Determine if `tui.agent.set { name }` or equivalent exists
- [ ] If not available: document as "blocked on upstream" or de-scope
- [ ] If available: implement deterministic agent switching

### Phase 2: Port Audit Commands (#17)

- [ ] Read `_tmp_ccplugins/pro/commands/audit.md`
- [ ] Read `_tmp_ccplugins/pro/commands/audit.quality.md`
- [ ] Read `_tmp_ccplugins/pro/commands/audit.repo.md`
- [ ] Read `_tmp_ccplugins/pro/commands/audit.security.md`
- [ ] Port each to `opencode/pro/commands/`
- [ ] Ensure backlog output targets `doc/.plan/backlog.json`

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
