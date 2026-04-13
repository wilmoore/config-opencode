# Plan: Port /pro:onboarding

## Goal

Port `_tmp_ccplugins/pro/commands/onboarding.md` into `opencode/pro/commands/onboarding.md` while aligning the workflow to the canonical `doc/.plan/` root and replacing any legacy `/pro:rules*` guidance with the toolkit-native `/rules:*` workflow.

## Constraints

- `doc/decisions/005-standardize-plan-root.md`: planning artifacts live under `doc/.plan/`.
- `doc/decisions/007-add-rules-toolkit-and-opt-in-agents-install.md`: `/rules:*` replaces legacy `/pro:rules*` guidance.
- Preserve the repo's existing command authoring style under `opencode/pro/commands/`.

## Inputs

- Roadmap brief: `doc/.plan/product/briefs/2026-03-08-ccplugins-port-roadmap.md`
- Existing related commands: `opencode/pro/commands/spec.md`, `backlog*.md`, `spike.md`
- Target backlog item: `doc/.plan/backlog.json` item `#16`

## Work Plan

1. Locate the latest ccplugins source for `/pro:onboarding`.
2. Translate the workflow into OpenCode command conventions.
3. Replace any reliance on `CLAUDE.md` or legacy `/pro:rules*` text with `/rules:*` guidance.
4. Verify the command text points to `doc/.plan/` and current toolkit workflows.

## Notes

- `/pro:evaluate.framework` has been moved earlier in the roadmap and should be the next ccplugins workflow evaluated after onboarding.
