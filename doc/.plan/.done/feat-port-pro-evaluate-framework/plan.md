# Plan: Port /pro:evaluate.framework

## Goal

Evaluate the new ccplugins `/pro:evaluate.framework` workflow and port it into the best OpenCode-native surface (likely a `/pro:*` command, not a skill), keeping behavior consistent with the existing ccplugins roadmap and local rules.

## Constraints

- `doc/decisions/005-standardize-plan-root.md`: all planning artifacts live under `doc/.plan/`.
- `doc/decisions/007-add-rules-toolkit-and-opt-in-agents-install.md`: prefer `/rules:*` over legacy `/pro:rules*` and keep rules provenance local.
- Follow existing `opencode/pro/commands/*` authoring style and avoid reliance on legacy `CLAUDE.md`/`AGENTS.md`.

## Inputs

- Backlog item `#33` in `doc/.plan/backlog.json`.
- ccplugins source: `_tmp_ccplugins/pro/commands/evaluate.framework.md` (updated from upstream).
- Related ADR: `_tmp_ccplugins/doc/decisions/073-evaluate-framework-command-architecture.md`.
- Roadmap brief: `doc/.plan/product/briefs/2026-03-08-ccplugins-port-roadmap.md` (step 5 after `onboarding.md`).

## Work Plan

1. ✅ Inspect the upstream `/pro:evaluate.framework` workflow and capture its intent, inputs, and outputs.
2. ✅ Decide the right OpenCode surface → `opencode/pro/commands/evaluate.framework.md`.
3. ✅ Translate the workflow into OpenCode command conventions:
   - Planning output goes to `doc/.plan/` (unchanged, command doesn't generate planning artifacts)
   - Framework reports go to `doc/frameworks/{name}.md` (same as upstream)
   - Uses `agent: build` frontmatter (OpenCode convention)
   - Removed ccplugins-specific references, made comparison target generic ("this project")
4. Document any behavior changes or de-scoping relative to ccplugins.
5. Update `doc/.plan/backlog.json` and roadmap docs if needed.

## Notes

- This item was explicitly pulled forward in the roadmap ahead of `/pro:audit*` and `quality-gate.md` to unblock later skills evaluation work.
- Updated `_tmp_ccplugins` from upstream (12 commits behind → synced)
- Fixed backlog: #16 (onboarding) marked completed, #33 marked in-progress with correct branch

## Behavior Changes from ccplugins

1. **Generic comparison target**: Changed from "ccplugins" to "this project" for flexibility
2. **Project type detection**: Added `opencode.json` and `opencode/` patterns for OpenCode projects
3. **No `allowed-tools` frontmatter**: OpenCode uses `agent: build` instead

## Remaining Tasks

- [ ] Commit the new command
- [ ] Test by running the command (optional - spike-based, can be tested later)
- [ ] Create PR
- [ ] Update backlog to completed
